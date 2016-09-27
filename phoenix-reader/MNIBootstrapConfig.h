//
//  MNIBootstrapConfig.h
//  Reader
//
//  Created by Yann Duran on 2/26/16.
//  Copyright © 2015 McClatchy Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIBootstrapConfigModel.h"

@interface MNIBootstrapConfig : NSObject <NSURLSessionDataDelegate, NSURLSessionTaskDelegate> {
    NSURLSession *_session;
}

+ (MNIBootstrapConfig *) sharedInstance;
- (MIBootstrapConfigModel *) bootStrap;
#ifdef DEBUG
- (void) setBootStrapWithJSONDictionary:(NSDictionary *)JSONDictionary;
- (void) setBootStrapConfigFile:(NSString *)filePath;
#endif
+ (UIColor *) menuTextColor;
+ (UIColor *) menuBackgroundColor;
+ (UIColor *) menuTintColor;
+ (UIColor *) menuHighlightBackgroundColor;
+ (UIColor *) menuHighlightTextColor;
+ (UIColor *) navMenuTintColor;
+ (UIColor *) barTintColor;
+ (UIColor *) barTitleColor;
+ (UIColor *) tintColor;
+ (UIColor *) sectionsMenuTintColor;
+ (UIColor *) sectionsMenuTextColor;
+ (UIColor *) sectionsMenuColor;
+ (UIColor *) sectionsMenuHighlightColor;
+ (UIColor *) sectionsHighlightMenuTextColor;
+ (NSString *) serverConfigUrl;
@end
