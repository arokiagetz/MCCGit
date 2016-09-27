//
//  AppDelegate.m
//  phoenix-reader
//
//  Created by Scott Ferwerda on 12/22/15.
//  Copyright © 2015 The McClatchy Company. All rights reserved.
//

#import "AppDelegate.h"
#import "MILog.h"
#import "MIDDCrashlyticsLogger.h"
#import "MIDDLogentriesLogger.h"
#import "MILogFormatter.h"
#import "MIFullLogFormatter.h"
#import "MNIDataController.h"
#import "MNIBootstrapConfig.h"
#import "MNIServerConfigManager.h"
#import "MNIErrorCentral.h"
#import "MNIThemeManager.h"
#import "UAirship.h"
#import "UAConfig.h"
#import "UAPush.h"
#import "MasterViewModels.h"
#import "MNIPageViewController.h"
#import "MNIWebViewController.h"
#import "RootSplitViewController.h"
#define LE_DEBUG_LOGS 0
#import <le/lelib.h>

// FIXME: Fabric and Crashlytics must be set up via portal at fabric.io before any Fabric stuff can be active in the app
//@import Fabric;
//@import Crashlytics;

extern NSString *const MNIStoryTapEventNotification;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
#ifndef DEBUG
    // FIXME: Fabric and Crashlytics must be set up via portal at fabric.io before any Fabric stuff can be active in the app
//    [Fabric with:@[CrashlyticsKit]];
    //to generate crash after 10 secs, uncomment next line
    //[[Crashlytics sharedInstance] performSelector:@selector(crash) withObject:nil afterDelay:10];
#endif
    [[MNIThemeManager sharedThemeManager] checkForSavedTheme];
    [self setupLogging];
    
    [self setupConfigFromBootstrap];
    if (launchOptions != nil) {
        NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo != nil) {
            NSString *storyId = [userInfo objectForKey:@"aps.alert"];
            [self getStoryIDfromPushNotification:storyId];
        }
    }
    MILogInfo(@"Startup complete.");
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[MNIDataController sharedDataController] persistMOCChanges:^(NSError *error) {
        if (error != nil) abort();
    }];
}



#pragma mark -

/*
 * NOTE: this needs to run after Crashlytics is initialized.
 */
- (void)setupLogging
{
    MILogFormatter *logFormatter = [[MILogFormatter alloc] init];
    
    DDASLLogger *aslLogger = [DDASLLogger sharedInstance];
    [aslLogger setLogFormatter:logFormatter];
    [DDLog addLogger:aslLogger];
    DDTTYLogger *ttyLogger = [DDTTYLogger sharedInstance];
    [ttyLogger setLogFormatter:logFormatter];
    [DDLog addLogger:ttyLogger];
    
#ifndef DEBUG
    // FIXME: Fabric and Crashlytics must be set up via portal at fabric.io before any Fabric stuff can be active in the app
//    MIDDCrashlyticsLogger *crashlyticsLogger = [[MIDDCrashlyticsLogger alloc] init];
//    [crashlyticsLogger setLogFormatter:logFormatter];
//    [DDLog addLogger:crashlyticsLogger];
    
    MIFullLogFormatter *fullLogFormatter = [[MIFullLogFormatter alloc] init];
    
    LELog* log = [LELog sharedInstance];
    log.token = @"c53e6c96-3ba7-4bb5-8e5e-117de9b28554";
    MIDDLogentriesLogger *logentriesLogger = [[MIDDLogentriesLogger alloc] init];
    [logentriesLogger setLogFormatter:fullLogFormatter];
    [DDLog addLogger:logentriesLogger withLevel:MILogLevelRemote];
#endif
    
    MILogInfo(@"Starting the McClatchy Interactive Reader ...");
    NSString *appExecutableName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"];
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *appShortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    MILogInfo(@"This is the %@ app, version %@(%@)", appExecutableName, appVersion, appShortVersion);
    
    MILogInfo(@"Logging level enable check ...");
    MILogError(   @"Error = on");
    MILogWarn(    @"Warning = on");
    MILogInfo(    @"Info = on");
    MILogDetailed(@"Detailed = on");
    MILogDebug(   @"Debug = on");
    MILogTrace(   @"Trace = on");
    MILogInfo(@"Logging level check complete.");
    MILogRemote(@"Remote Logging Active");
}

- (void)setupConfigFromBootstrap
{
    NSString *serverConfigUrlString = [[[MNIBootstrapConfig sharedInstance] bootStrap] server_config_url];
    NSAssert(serverConfigUrlString.length > 0, @"unable to read bootstrap configuration");
    // TODO: log error to remote, inform user we are dead
    if (serverConfigUrlString.length > 0) {
        MILogDebug(@"Attempting to initialize server config manager with URL %@.", serverConfigUrlString);
        
        NSURL *serverConfigUrl = [NSURL URLWithString:serverConfigUrlString];
        MNIDataController *dataController = [MNIDataController sharedDataController];
        MNIServerConfigManager *configManager = [MNIServerConfigManager initSharedManagerWithURL:serverConfigUrl andDataController:dataController];
        
        NSAssert(configManager != nil, @"unable to construct a server config manager");
        // TODO: log error to remote, inform user we are dead
        
        MILogDetailed(@"Fetching config from server due to app coldstart.");
        [configManager fetchServerConfigWithSuccessBlock:^(MNIServerConfigModel *aServerConfigModel, NSDate *lastUpdatedDate) {
            MILogDetailed(@"Coldstart server config fetch complete.");
            [self setupUrbanAirship];
        } andFailureBlock:^(NSError *error) {
            MILogDetailed(@"Coldstart server config fetch failed: %@ (%@)", error.localizedDescription, error.localizedFailureReason);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[MNIErrorCentral sharedErrorCentral] presentError:error withOptionsAndCallbacks:@"Retry", ^void{
//                    [self setupConfigFromBootstrap];
                }, nil];
            });
        }];
    }
}

#pragma mark - Push Notifications Delegate method

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSString *storyId = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    [self getStoryIDfromPushNotification:storyId];
}
#pragma mark - Push Notifications
- (void)setupUrbanAirship {
    
    MNIConfigUrbanAirshipModel *mniConfig = [[[[MNIServerConfigManager sharedManager] serverConfigModel] push_notifications]urban_airship];
    if (!mniConfig) {
        return;
    }
    if (!mniConfig.enabled) {
        return;
    }
    
    UAConfig *config = [UAConfig defaultConfig];
    config.inProduction = mniConfig.in_production;
    config.developmentAppKey = mniConfig.dev_app_key;
    config.developmentAppSecret = mniConfig.dev_app_secret;;
    config.productionAppKey = mniConfig.prod_app_key;
    config.productionAppSecret = mniConfig.prod_app_secret;
    [UAirship takeOff:config];
    [UAirship push].userNotificationTypes = (UIUserNotificationTypeAlert |
                                             UIUserNotificationTypeBadge |
                                             UIUserNotificationTypeSound);
    [UAirship push].userPushNotificationsEnabled = mniConfig.enabled;
}
-(void)getStoryIDfromPushNotification:(NSString*)pushMessage{
    if ([[pushMessage pathExtension] isEqualToString:@"html"] && ([pushMessage.lowercaseString hasPrefix:@"http://"] || [pushMessage.lowercaseString hasPrefix:@"https://"])) {
        if ([pushMessage rangeOfString:@"article" options:NSCaseInsensitiveSearch].location != NSNotFound && [pushMessage rangeOfString:@"html" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            NSRange r1 = [pushMessage rangeOfString:@"article"];
            NSRange r2 = [pushMessage rangeOfString:@".html"];
            NSRange rSub = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
            NSString *subString = [pushMessage substringWithRange:rSub];
            if (subString!=nil && ![subString isEqualToString:@""]) {
                MNIServerConfigModel *configModel = [[MNIServerConfigManager sharedManager] serverConfigModel];
                NSString *baseUrl = configModel.apiInfo.baseUrl;
                NSString *storyurl = [NSString stringWithFormat:@"%@v1/articles/%@",baseUrl,subString];
                //Load StoryView when the Url have Story Id
                [self loadStoryViewFromPushMessage:storyurl];
            } else {
                // Load InAppBowser When the Url dont have article Id
                [self loadInAppBrowserViewFromPushMessage:pushMessage];
            }
        } else {
            // Load InAppBowser When the Url dont have article and html string
            [self loadInAppBrowserViewFromPushMessage:pushMessage];
        }
    } else if ([pushMessage.lowercaseString hasPrefix:@"http://"] || [pushMessage.lowercaseString hasPrefix:@"https://"]){
        // Load InAppBowser When the Notification have Url and it is not the story url.
        [self loadInAppBrowserViewFromPushMessage:pushMessage];
    } else {
        //Load MSSF When No url
    }
}
-(void)loadStoryViewFromPushMessage:(NSString*)storyUrl{
    MNIURLDownloader *downloader = [[MNIURLDownloader alloc] initWithSession:nil];
    __block NSMutableArray *array = [NSMutableArray array];
    
    [downloader downloadDataFromUrl:[NSURL URLWithString:storyUrl] withSuccessBlock:^(NSData *data) {
        NSError *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (!error) {
            NSError *adapterError;
            MNIStoryModel *model = [MTLJSONAdapter modelOfClass:[MNIStoryModel class] fromJSONDictionary:result error:&adapterError];
            if (adapterError) {
                MILogError(@"error in MTLJSONAdapter: %@",adapterError);
                model = nil;
                //Load InAppBrowser when story model value is empty
                [self loadInAppBrowserViewFromPushMessage:storyUrl];
            }
            MasterViewModelItem *aVMItem = [[MasterViewModelItem alloc] init];
            aVMItem.storyModel = model;
            [array addObject:aVMItem];
            dispatch_async( dispatch_get_main_queue(), ^{
                if (model!=nil) {
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PagerViewNavController"];
                    MNIPageViewController *pageViewController = [(UINavigationController*)vc viewControllers][0];
                    [pageViewController setStories:array];
                    [pageViewController setCurrentIndex:0];
                    pageViewController.fromPushMessage = YES;
                    [self.window.rootViewController presentViewController:vc animated:YES completion:nil];
                }
            });
        }
    } andFailureBlock:^(NSError *error) {
        dispatch_async( dispatch_get_main_queue(), ^{
             //Load InAppBrowser when data is not downloaded
            [self loadInAppBrowserViewFromPushMessage:storyUrl];
        });
    }];
}
-(void)loadInAppBrowserViewFromPushMessage:(NSString*)storyUrl{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    MNIWebViewController *webViewController = [(UINavigationController*)vc viewControllers][0];
    webViewController.theUrl = [NSURL URLWithString:storyUrl];
    webViewController.theTitle = @"New Story";
    [self.window makeKeyAndVisible];
    [self.window.rootViewController presentViewController:vc animated:YES completion:nil];
}
@end
