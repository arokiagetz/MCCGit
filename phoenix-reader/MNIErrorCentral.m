//
//  MNIErrorCentral.m
//  phoenix-reader
//
//  Created by Yann Duran on 3/28/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//
//
//  Usage:
//
//  [[MNIErrorCentral sharedErrorCentral] presentError:error withOptionsAndCallbacks:
//   @"Ok",^void{
//       NSLog(@"ok");
//   },
//   @"retry",^void{
//       NSLog(@"try");
//   }, nil];
//
//   Note: A call to presentError without options/callbacks will block ui (alert with no action buttons)
//

#import "MNIErrorCentral.h"
#import "MILog.h"

NSString *kErrorDomainForHttpStatus = @"MNIHTTPStatusError";
NSString *kErrorDomainForApiBadData = @"MNIAPIResponseError";
// keep adding custom domain here...

@implementation MNIErrorCentral

+ (instancetype)sharedErrorCentral
{
    static MNIErrorCentral *sharedErrorCentral = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedErrorCentral = [MNIErrorCentral new];
    });
    return sharedErrorCentral;
}

- (instancetype)init
{
    if(!(self = [super init]))
        return nil;
    _outstandingAlertContexts = [NSMutableArray new];
    _queuedAlertContexts = [NSMutableArray new];
    return self;
}

- (void)presentError:(NSError *)error withOptionsAndCallbacks:(id)name, ...
{
    // Log it...
    MILogError(@"error (%@)",error.localizedDescription);
    // ...
    
    NSMutableArray *recoveryOptions = [NSMutableArray new];
    NSMutableArray *recoveryCallbacks = [NSMutableArray new];
    
    va_list va;
    va_start(va, name);
    
    OptionCallBack callback = va_arg(va, OptionCallBack);
    [recoveryOptions addObject:name];
    [recoveryCallbacks addObject:[callback copy]];
    
    while((name = va_arg(va, NSString*))) {
        OptionCallBack callback = va_arg(va, OptionCallBack);
        [recoveryOptions addObject:name];
        [recoveryCallbacks addObject:[callback copy]];
    }
    
    va_end(va);
    
    // using alertController to display errors to user, refactor if using a different UI object
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[error localizedDescription]
                                                                   message:[error localizedFailureReason]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    

    for (NSString *option in recoveryOptions) {
        OptionCallBack callback = [recoveryCallbacks objectAtIndex:[recoveryOptions indexOfObject:option]];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:option style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  callback();
                                                                  [self removeAlertContextWithAction:action];
                                                              }];

        [alert addAction:defaultAction];
    }
    
    MNIErrorCentralAlertContext *newAlertContext = [[MNIErrorCentralAlertContext alloc] init];
    newAlertContext.alert = alert;
    newAlertContext.context = [[NSUUID UUID] UUIDString]; // this could be usefull later
    
    [self.outstandingAlertContexts addObject:newAlertContext];
    
    // Already have an alert on screen?
    if (self.outstandingAlertContexts.count > 1) {
        [self.queuedAlertContexts addObject:newAlertContext];
        return;
    }
    
    [newAlertContext showAlert];
}

- (void)presentQueuedErrors
{
    MNIErrorCentralAlertContext *alertContext = self.queuedAlertContexts.firstObject;
    if (!alertContext)
        return;
    
    [alertContext showAlert];
}

- (void)removeAlertContextWithAction:(UIAlertAction *)action
{
    for (MNIErrorCentralAlertContext *context in self.outstandingAlertContexts.copy) {
        if ([context.alert.actions containsObject:action]) {
            [self.outstandingAlertContexts removeObject:context];
            [self.queuedAlertContexts removeObject:context];
            break;
        }
    }

    [self presentQueuedErrors];
}

+ (NSError *)customErrorWithDomain:(NSString *)domain code:(NSInteger)code andUserInfo:(NSDictionary *)userInfo
{
    NSError *error = [NSError errorWithDomain:domain
                                         code:code
                                     userInfo:userInfo];
    
    return error;
}

+ (NSDictionary *)userInfoForHTTPUrlResponseWithStatusCode:(NSInteger)code
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSHTTPURLResponse localizedStringForStatusCode:code]};
    return userInfo;
}

+ (NSDictionary *)userInfoWithDescription:(NSString *)description andReason:(NSString *)reason
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : description, NSLocalizedFailureReasonErrorKey : reason};
    return userInfo;
}

@end

#pragma mark - MNIErrorCentralAlertContext

@implementation MNIErrorCentralAlertContext

- (void)showAlert
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:self.alert animated:YES completion:nil];
}

@end



