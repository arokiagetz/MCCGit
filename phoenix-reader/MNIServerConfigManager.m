//
//  MNIServerConfigManager.m
//  phoenix-reader
//
//  Created by Scott Ferwerda on 3/14/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNIServerConfigManager+Testable.h"
#import "MILog.h"
#import <BlocksKit/BlocksKit.h>
#import "MNIGlobalConstants.h"

NSString * const MNIServerConfigDidUpdateNotification = @"MNIServerConfigDidUpdateNotification";
NSString * const MNIServerConfigDidFailToUpdateNotification = @"MNIServerConfigDidFailToUpdateNotification";

#define MNI_SERVER_CONFIG_OBJECT_VERSION 1

// define this TTL in seconds - so 12 hours is 12*60*60
#define SERVER_CONFIG_TTL (12 * 60 * 60)

@interface MNIServerConfigManager ()
{
    MNIServerConfigModel *_serverConfigModel;
    NSURL *_serverConfigUrl;
    MNIURLDownloader *_downloader;
}

@property MNIDataController *dataController;

@end

@implementation MNIServerConfigManager

//NSString * const entityNameMNIServerConfig = @"MNIServerConfig";

static id shared_MNIServerConfigManager = nil;

+ (instancetype)sharedManager
{
    @synchronized(self) {
        return shared_MNIServerConfigManager;
    }
}

+ (instancetype)initSharedManagerWithURL:(NSURL *)url andDataController:(MNIDataController *)dataController
{
    @synchronized(self) {
        NSAssert(shared_MNIServerConfigManager == nil, @"attempt to re-initialize shared server config manager");
        
        shared_MNIServerConfigManager = [[self alloc] initWithURL:url andDataController:dataController];
        
        return shared_MNIServerConfigManager;
    }
}

- (instancetype)initWithURL:(NSURL *)url andDataController:(MNIDataController *)dataController
{
    NSAssert([[url absoluteString] length] > 0, @"attempt to construct config manager with empty url");
    NSAssert(dataController != nil, @"attempt to construct config manager with empty data controller");
    self = [super init];
    if (self) {
        _serverConfigUrl = [url copy];
        _dataController = dataController;
        _serverConfigModel = nil;
        _lastUpdatedDate = nil;
    }
    return self;
}

#pragma mark - getters/setters

- (MNIServerConfigModel *)serverConfigModel
{
    __block MNIServerConfigModel *result = nil;
    
    if (_serverConfigModel != nil) {
        result = _serverConfigModel;
    }
    else {
        NSManagedObjectContext *mainMOC = [self.dataController mainManagedObjectContext];
        [mainMOC performBlockAndWait:^{
            NSError *blockError = nil;
            // get any existing server config
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[MNIServerConfig entityName]];
            NSArray *fetchResults = [mainMOC executeFetchRequest:fetchRequest error:&blockError];
            if (blockError == nil) {
                // there shouldn't be more than one result, but let's be safe
                MNIServerConfig *aServerConfig = [fetchResults firstObject];
                if (aServerConfig != nil) {
                    _serverConfigModel = (MNIServerConfigModel *)(aServerConfig.mniServerConfigModel);
                    if (_serverConfigModel != nil) {
                        _lastUpdatedDate = aServerConfig.lastUpdated;
                        result = _serverConfigModel;
                    }
                    else {
                        MILogError(@"The fetched server config model was unexpectedly nil.");
                    }
                }
                else {
                    MILogError(@"Server config fetch unexpectedly returned a nil value.");
                }
            }
            else {
                MILogError(@"Core Data error fetching server config: %@", blockError);
            }
        }];
    }
    
    return result;
}

- (NSURL *)serverConfigUrl
{
    return _serverConfigUrl;
}

- (void)setServerConfigUrl:(NSURL *)serverConfigUrl
{
    _serverConfigUrl = serverConfigUrl;
}

- (MNIURLDownloader *)downloader
{
    return _downloader;
}

- (void)setDownloader:(MNIURLDownloader *)downloader
{
    _downloader = downloader;
}

#pragma mark - public methods

- (void)fetchServerConfigIfNeeded
{
    [self fetchServerConfigIfNeededWithSuccessBlock:NULL andFailureBlock:NULL];
}

- (void)fetchServerConfigIfNeededWithSuccessBlock:(void (^)(MNIServerConfigModel *aServerConfigModel, NSDate *lastUpdatedDate))success andFailureBlock:(void (^)(NSError *error))failure
{
    if ([self serverConfigIsStale]) {
        [self fetchServerConfigWithSuccessBlock:success andFailureBlock:failure];
    }
}

#pragma mark - private methods

- (BOOL)serverConfigIsStale
{
    // assume we are stale, then check to see if perhaps we aren't
    BOOL isStale = YES;
    
    // do we have a server config?
    if (_serverConfigModel != nil) {
        // if so, is it stale?
        if (_lastUpdatedDate != nil) {
            NSDate *dateNow = [NSDate date];
            NSTimeInterval secondsSinceUpdate = [dateNow timeIntervalSinceDate:_lastUpdatedDate];
            if (secondsSinceUpdate >= 0 && secondsSinceUpdate <= SERVER_CONFIG_TTL) {
                isStale = NO;
            }
        }
    }
    return  isStale;
}

- (void)fetchServerConfig
{
    [self fetchServerConfigWithSuccessBlock:NULL andFailureBlock:NULL];
}

- (void)fetchServerConfigWithSuccessBlock:(void (^)(MNIServerConfigModel *aServerConfigModel, NSDate *lastUpdatedDate))success andFailureBlock:(void (^)(NSError *error))failure
{
    if (self.downloader == nil) self.downloader = [[MNIURLDownloader alloc] initWithSession:nil];
    [self.downloader downloadDataFromUrl:self.serverConfigUrl withSuccessBlock:^(NSData *data) {
        [self handleReceivedData:data];
        if (success != NULL) {
            success(self.serverConfigModel, self.lastUpdatedDate);
        }
        self.downloader = nil;
    } andFailureBlock:^(NSError *error) {
        [self handleFailureToReceiveDataWithError:error];
        if (failure != NULL) {
            failure(error);
        }
        self.downloader = nil;
    }];
}

#pragma mark - server fetch result handlers

- (void)handleReceivedData:(NSData *)data
{
    BOOL success = NO;
    
    // see if we can make a dictionary out of the data
    NSDictionary *jsonDict = nil;
    NSError *error = nil;
    if (data != nil) {
        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error == nil) {
            if ([jsonData isKindOfClass:[NSDictionary class]]) {
                jsonDict = jsonData;
            }
        }
        else {
            // TODO: report error to global handler (yet to be written, see ticket MOBI-2396)
        }
    }
    
    if (jsonDict != nil) {
        // save the config
        success = [self updateServerConfigFromDictionary:jsonDict error:&error];
        if (error != nil) {
            // TODO: report error to global handler (yet to be written, see ticket MOBI-2396)
        }
    }
    
    if (success) {
        // send update ready note
        NSMutableDictionary *userInfoDict = [[NSMutableDictionary alloc] init];
        userInfoDict[@"url"] = self.serverConfigUrl;
//        userInfoDict[@"config"] = self.serverConfigModel;
        NSNotification *note = [NSNotification notificationWithName:MNIServerConfigDidUpdateNotification object:self userInfo:userInfoDict];
        [[NSNotificationQueue defaultQueue] enqueueNotification:note postingStyle:NSPostASAP];
    }
    else {
        // send failed note
        NSMutableDictionary *userInfoDict = [[NSMutableDictionary alloc] init];
        userInfoDict[@"url"] = self.serverConfigUrl;
        if (error != nil) userInfoDict[@"error"] = error;
        NSNotification *note = [NSNotification notificationWithName:MNIServerConfigDidFailToUpdateNotification object:self userInfo:userInfoDict];
        [[NSNotificationQueue defaultQueue] enqueueNotification:note postingStyle:NSPostASAP];
    }
}

- (void)handleFailureToReceiveDataWithError:(NSError *)error
{
    // send failed note
    NSMutableDictionary *userInfoDict = [[NSMutableDictionary alloc] init];
    userInfoDict[@"url"] = self.serverConfigUrl;
    if (error != nil) userInfoDict[@"error"] = error;
    NSNotification *note = [NSNotification notificationWithName:MNIServerConfigDidFailToUpdateNotification object:self userInfo:userInfoDict];
    [[NSNotificationQueue defaultQueue] enqueueNotification:note postingStyle:NSPostASAP];
}

#pragma mark -

- (BOOL)updateServerConfigFromDictionary:(NSDictionary *)dictionary error:(NSError **)errorPtr
{
    __block BOOL success = NO;
    
    NSDictionary *configDictonary = [self addTopStoryDictonatToConfigDictonaty:dictionary];
    
    // store the data to core data:
    
    // get a worker MOC
    NSManagedObjectContext *workerMOC = [self.dataController workerObjectContext];
    
    // do our fetching and updating on the worker MOC private queue
    // we have to wait here, so error and success status are properly returned to caller
    [workerMOC performBlockAndWait:^{
        NSError *blockError = nil;
        // get any existing server config
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[MNIServerConfig entityName]];
        NSArray *fetchResults = [workerMOC executeFetchRequest:fetchRequest error:&blockError];
        if (blockError == nil) {
            // there shouldn't be more than one result, but let's be safe
            MNIServerConfig *serverConfig = [fetchResults firstObject];
            if (serverConfig == nil) {
                // no object found in core data, so make a new one
                serverConfig = [NSEntityDescription insertNewObjectForEntityForName:[MNIServerConfig entityName] inManagedObjectContext:workerMOC];
            }
            
            // we really should have a server config object by now
            BOOL didUpdateObject = NO;
            if (serverConfig != nil) {
                if ([serverConfig setMniServerConfigModelFromDictionary:configDictonary]) {
                    serverConfig.version = @(MNI_SERVER_CONFIG_OBJECT_VERSION);
                    serverConfig.lastUpdated = [NSDate date];
                    didUpdateObject = YES;
                    // saved - so store
                    _serverConfigModel = (MNIServerConfigModel *)(serverConfig.mniServerConfigModel);
                    _lastUpdatedDate = serverConfig.lastUpdated;
                }
                else {
                    // server config couldn't be created from the dictionary - this is an error
                    MILogError(@"failed to update server config from dictionary");
                }
            }
            
            if (didUpdateObject) {
                // remove any other server config objects in the array (we only support one instance of a server config in core data)
                if (fetchResults.count > 1) {
                    for (NSUInteger i = 1; i < fetchResults.count; i++) {
                        MNIServerConfig *aStaleConfig = fetchResults[i];
                        [workerMOC deleteObject:aStaleConfig];
                    }
                }
                
                success = YES;
            }
            
            for (MNIConfigSectionModel *sectionModel in self.serverConfigModel.sections_info.sections) {
                
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[MNISection entityName]];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sectionID == %@ && contentType == %@ && name == %@",sectionModel.section_id, sectionModel.contentType, sectionModel.name];
                [fetchRequest setPredicate:predicate];
                
                [workerMOC performBlock:^{
                    NSError *blockError = nil;
                    NSArray *fetchResults = [workerMOC executeFetchRequest:fetchRequest error:&blockError];
                    MNISection *section = [fetchResults firstObject];
                    if (!section) {
                        section = [NSEntityDescription insertNewObjectForEntityForName:[MNISection entityName] inManagedObjectContext:workerMOC];
                    }
                    section.name = sectionModel.name;
                    section.sectionID = sectionModel.section_id;
                    section.contentType = sectionModel.contentType;
                    section.type = [NSNumber numberWithInt:sectionModel.type];
                    section.sortOrder = [NSNumber numberWithInteger:[self.serverConfigModel.sections_info.sections indexOfObject:sectionModel]];
                    section.url = sectionModel.url;
                    section.timeStamp = [NSDate date];
                    section.isMainSection = @1;
                    
                    NSMutableSet *sectionsSet = [[NSMutableSet alloc] init];
                    for (MNIConfigSectionModel *subSectionModel in sectionModel.sections) {
                        subSectionModel.parentConfigSection = sectionModel;
                        
                        NSArray *sectionsArray = [NSArray arrayWithArray:[section.sections allObjects]];
                        MNISection *subSection = [sectionsArray bk_match:^BOOL(MNISection *obj) {
                            return [obj.sectionID isEqualToString:subSectionModel.section_id] && [obj.contentType isEqualToString:subSectionModel.contentType] && [obj.name isEqualToString:subSectionModel.name];
                        }];
                        
                        if (!subSection) {
                            subSection = [NSEntityDescription insertNewObjectForEntityForName:[MNISection entityName] inManagedObjectContext:workerMOC];
                        }
                        
                        subSection.name = subSectionModel.name;
                        subSection.sectionID = subSectionModel.section_id;
                        subSection.contentType = subSectionModel.contentType;
                        subSection.type = [NSNumber numberWithInt:subSectionModel.type];
                        subSection.sortOrder = [NSNumber numberWithInteger:[sectionModel.sections indexOfObject:subSectionModel]];
                        subSection.url = subSectionModel.url;
                        subSection.timeStamp = [NSDate date];
                        section.isMainSection = @0;
                        
                        [sectionsSet addObject:subSection];
                    }
                    [section addSections:sectionsSet];
                }];
            }
            // we've made all necessary changes to the MOC - now save it
            [self.dataController persistWorkerMOCChanges:workerMOC withCompletion:^(NSError *blockError) {
                // nothing to do here
            }];
        }
        else {
            // fetch had an error
            MILogError(@"Core Data error searching for config data to update.");
        }
        
        if (errorPtr != NULL) {
            *errorPtr = blockError;
        }
    }];
    return success;
}

- (NSDictionary *)addTopStoryDictonatToConfigDictonaty:(NSDictionary *)dictionary {
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    NSArray *allSection = dictionary[@"sections_info"][@"sections"];
    NSString *topSectionId = dictionary[@"sections_info"][@"multisection"][@"top_story_section_id"];
    
    NSDictionary *topSection = [allSection bk_match:^BOOL(NSDictionary *obj) {
        return [obj[@"section_id"] isEqualToString:topSectionId];
    }];
    
    if (topSection) {
        NSMutableDictionary *topDict = [topSection mutableCopy];
        [topDict setObject:MNITopSectionName forKey:@"name"];
        NSMutableArray *sections = [NSMutableArray arrayWithObject:topDict];
        [sections addObjectsFromArray:allSection];
        NSDictionary *sectionInfo = @{@"sections":sections, @"multisection":dictionary[@"sections_info"][@"multisection"], @"stories_shown_per_section":dictionary[@"sections_info"][@"stories_shown_per_section"]};
        [tempDict setObject:sectionInfo forKey:@"sections_info"];
    }
    return tempDict;
}

@end
