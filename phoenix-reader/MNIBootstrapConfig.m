//
//  MNIBootstrapConfig.m
//  Reader
//
//  Created by Yann Duran on 2/26/16.
//  Copyright © 2015 McClatchy Interactive. All rights reserved.
//

#import "MNIBootstrapConfig.h"
#import <Mantle/Mantle.h>
#import "MILog.h"
#import "UIColor+ColorHelpers.h"

static MNIBootstrapConfig *sharedInstance = nil;
static MIBootstrapConfigModel *bootStrap = nil;
static NSString *bootStrapConfigFile = nil;

@implementation MNIBootstrapConfig

+ (MNIBootstrapConfig *) sharedInstance
{
    @synchronized (self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }
    }
    
    return sharedInstance;
}

- (MIBootstrapConfigModel *)bootStrap
{
    if (bootStrap == nil) {
        NSError *deserializingError;
        if (bootStrapConfigFile == nil) {
            bootStrapConfigFile = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CONFIG_FILE"];
        }
        NSArray *nameComponents = [bootStrapConfigFile componentsSeparatedByString:@"."];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:nameComponents[0] ofType:nameComponents[1]];
        NSData *contentOfLocalFile = [NSData dataWithContentsOfFile:filePath];
        if (contentOfLocalFile) {
            id object = [NSJSONSerialization JSONObjectWithData:contentOfLocalFile
                                                        options:kNilOptions
                                                          error:&deserializingError];
            if (deserializingError) {
                MILogError(@"Config :: error in NSJSONSerialization (%@)",deserializingError.localizedDescription);
                return nil;
            }
            
            NSError *adapterError;
            bootStrap = [MTLJSONAdapter modelOfClass:[MIBootstrapConfigModel class] fromJSONDictionary:object error:&adapterError];
            if (adapterError) {
                MILogError(@"Config :: error in MTLJSONAdapter (%@)",adapterError.localizedDescription);
                return nil;
            }
        }
        else {
            return nil;            
        }
    }
    
    return bootStrap;
}

- (void) setBootStrapConfigFile:(NSString *)filePath
{
#   ifdef DEBUG
        bootStrapConfigFile = filePath;
        bootStrap = nil;//force reload bootstrap
#   endif
}

- (void) setBootStrapWithJSONDictionary:(NSDictionary *)JSONDictionary
{
#   ifdef DEBUG
        NSError *adapterError;
        bootStrap = [MTLJSONAdapter modelOfClass:[MIBootstrapConfigModel class] fromJSONDictionary:JSONDictionary error:&adapterError];
#   endif
}

+(NSString *)serverConfigUrl
{
    return [[[self sharedInstance] bootStrap] server_config_url];
}

+(UIColor *)colorFromConfig : (NSString *) configColor
{
    return configColor ? ([UIColor getUIColorObjectFromHexString:configColor alpha:1.0]) : [UIColor blackColor];
}

+(UIColor *)barTintColor
{
    return [self colorFromConfig:[[[self sharedInstance] bootStrap] barTintColor]];
}

+(UIColor *)barTitleColor
{
    return [self colorFromConfig:[[[self sharedInstance] bootStrap] barTitleColor]];
}

+(UIColor *)tintColor
{
    return [self colorFromConfig:[[[self sharedInstance] bootStrap] tintColor]];
}

+(UIColor *)sectionsMenuTintColor
{
    return [self colorFromConfig:[[[self sharedInstance] bootStrap] sectionsMenuTintColor]];
}

+(UIColor *)sectionsMenuHighlightColor
{
    return [self colorFromConfig:[[[self sharedInstance] bootStrap] sectionsMenuHighlightColor]];
}

+(UIColor *)sectionsMenuColor
{
    return [self colorFromConfig:[[[self sharedInstance] bootStrap] sectionsMenuColor]];
}

+(UIColor *)sectionsMenuTextColor
{
    return [self colorFromConfig:[[[self sharedInstance] bootStrap] sectionsMenuTextColor]];
}

+(UIColor *)sectionsHighlightMenuTextColor
{
    return [self colorFromConfig:[[[self sharedInstance] bootStrap] sectionsMenuHighlightTextColor]];
}

+ (UIColor*)menuTextColor
{
    return [self colorFromConfig:[[[self sharedInstance] bootStrap] sectionsMenuTextColor]];
}

+ (UIColor*)menuBackgroundColor
{
    return [self colorFromConfig:[[[self sharedInstance] bootStrap] sectionsMenuColor]];
}

+ (UIColor*)menuTintColor
{
    return [self colorFromConfig:[[[self sharedInstance] bootStrap] sectionsMenuTintColor]];
}

+(UIColor *)navMenuTintColor
{
    return [self colorFromConfig:[[[self sharedInstance] bootStrap] sectionsMenuTintColor]];
}

+ (UIColor*)menuHighlightBackgroundColor
{
    return [self colorFromConfig:[[[self sharedInstance] bootStrap] sectionsMenuHighlightColor]];
}

+ (UIColor*)menuHighlightTextColor
{
    return [self sectionsHighlightMenuTextColor];
}

@end
