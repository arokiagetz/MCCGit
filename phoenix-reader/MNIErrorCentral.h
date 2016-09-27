//
//  MNIErrorCentral.h
//  phoenix-reader
//
//  Created by Yann Duran on 3/28/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *kErrorForHttpStatus;
extern NSString *kErrorDomainForApiBadData;

typedef void(^OptionCallBack)();

@interface MNIErrorCentral : NSObject <UIAlertViewDelegate>

@property(nonatomic) NSMutableArray *outstandingAlertContexts;
@property(nonatomic) NSMutableArray *queuedAlertContexts;

+ (instancetype)sharedErrorCentral;
- (void)presentError:(NSError *)error withOptionsAndCallbacks:(id)name, ... NS_REQUIRES_NIL_TERMINATION;

// helpers
+ (NSError *)customErrorWithDomain:(NSString *)domain code:(NSInteger)code andUserInfo:(NSDictionary *)userInfo;
+ (NSDictionary *)userInfoForHTTPUrlResponseWithStatusCode:(NSInteger)code;
+ (NSDictionary *)userInfoWithDescription:(NSString *)description andReason:(NSString *)reason;

@end

#pragma mark - MNIErrorCentralAlertContext

@interface MNIErrorCentralAlertContext : NSObject

@property (nonatomic) UIAlertController *alert;
@property (nonatomic) NSString *context;

- (void)showAlert;

@end


