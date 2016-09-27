//
//  MNIServerConfigModels.m
//  Reader
//
//  Created by Yann Duran on 10/19/15.
//  Copyright © 2015 McClatchy Interactive. All rights reserved.
//

#import "MNIServerConfigModels.h"
#import "MNIServerConfigManager.h"
#import "MNIGlobalConstants.h"

#pragma mark - UI / BootStrap


#pragma mark - Api Info

@implementation MNIConfigApiInfoModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"baseUrl": @"base_url",
             @"publication": @"publication",
             };
}

@end

#pragma mark - Alerts

@implementation MNIConfigAlertModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"type": @"type",
             @"timestamp": @"timestamp",
             @"text": @"text",
             @"header_text": @"header_text",
             @"persistent": @"persistent",
             @"link": @"link",
             @"link_text": @"link_text",
             @"app_versions": @"app_versions",
             @"os_versions": @"os_versions"
            };
}

+ (NSValueTransformer *)app_versionsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIConfigAlertVersionsModel class]];
}

+ (NSValueTransformer *)os_versionsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIConfigAlertVersionsModel class]];
}

@end

@implementation MNIConfigAlertVersionsModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"modifier": @"modifier",
             @"versions": @"versions"
             };
}

+ (NSValueTransformer *)modifierJSONTransformer {
    NSDictionary *mapping = @{
                              @"above": @(MNIAlertModifierAbove),
                              @"below": @(MNIAlertModifierBelow),
                              @"between": @(MNIAlertModifierBetween)
                              };
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:mapping];
}

@end

#pragma mark - Weather

@implementation MNIConfigAccuweatherModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"api_key": @"api_key",
             @"dev_mode": @"dev_mode",
             @"enabled": @"enabled",
             @"icons_base_url": @"icons_base_url",
             @"location_key": @"location_key",
             @"partner_id": @"partner_id"
             };
}

@end

@implementation MNIConfigWeatherModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"accuweather": @"accuweather"
             };
}

@end

#pragma mark - Paywall


@implementation MNIConfigPressPlusModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"api_key": @"api_key",
             @"enabled": @"enabled",
             @"zone_uuid": @"zone_uuid"
             };
}

@end

@implementation MNIConfigSyncronexModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"client_info": @"client_info",
             @"company": @"company",
             @"content_id": @"content_id",
             @"dev_mode": @"dev_mode",
             @"enabled": @"enabled",
             @"minutes_tracked": @"minutes_tracked",
             @"publication": @"publication",
             @"iap_product_ids" : @"iap_product_ids",
             @"iap_shared_secret" : @"iap_shared_secret"
             };
}

@end

@implementation MNIConfigPayWallModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"press_plus": @"press_plus",
             @"syncronex": @"syncronex"
             };
}

@end

#pragma mark - Push

@implementation MNIConfigUrbanAirshipModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"debug_logging": @"debug_logging",
             @"dev_app_key": @"dev_app_key",
             @"dev_app_secret": @"dev_app_secret",
             @"enabled": @"enabled",
             @"in_production": @"in_production",
             @"prod_app_key": @"prod_app_key",
             @"prod_app_secret": @"prod_app_secret"
             };
}

@end

@implementation MNIConfigPushNotificationsModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"urban_airship": @"urban_airship"
             };
}

@end

#pragma mark - Analytics

@implementation MNIConfigOmnitureModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"biz_unit": @"biz_unit",
             @"debug_logging": @"debug_logging",
             @"enabled": @"enabled",
             @"publication": @"publication",
             @"rsid": @"rsid",
             @"server": @"server",
             @"appid" : @"appid"
             };
}

@end

@implementation MNIConfigAnalyticsModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"omniture": @"omniture"
             };
}

@end

#pragma mark - About

@implementation MNIConfigAboutModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"contact_email": @"contact_email",
             @"copyright": @"links.copyright",
             @"privacy_policy": @"links.privacy_policy",
             @"terms_of_service": @"links.terms_of_service"
             };
}

@end

#pragma mark - Video

@implementation MNIConfigYoutubeModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"api_key": @"api_key"
             };
}

@end

@implementation MNIConfigVideoModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"youtube": @"youtube"
             };
}

@end

#pragma mark - Social

@implementation MNIConfigSocialFacebookModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"api_key": @"api_key",
             @"enabled" : @"enabled"
             };
}

@end

@implementation MNIConfigSocialGooglePlusModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"client_id": @"client_id"
             };
}

@end

@implementation MNIConfigSocialModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"facebook": @"facebook",
             @"google_plus": @"google_plus"
             };
}

@end


#pragma mark - Sections

@implementation MNIConfigSectionModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"ad_channel": @"ad_channel",
             @"ad_sect": @"ad_sect",
             @"name": @"name",
             @"type": @"type",
             @"url": @"url",
             @"section_id": @"section_id",
             @"sections": @"sections",
             @"contentType": @"content_type"
             };
}

+ (NSValueTransformer *)typeJSONTransformer {
    NSDictionary *mapping = @{
                              @"section": @(MNISectionTypeSection),
                              @"multisection": @(MNISectionTypeMultiSection),
                              @"youtube": @(MNISectionTypeYoutube),
                              @"web": @(MNISectionTypeWeb),
                              @"gallery": @(MNISectionTypeGallery),
                              @"phone": @(MNISectionMSSPhone),
                              @"tablet": @(MNISectionMSSTablet)
                              };
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:mapping];
}

+ (NSValueTransformer *)sectionsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIConfigSectionModel class]];
}

- (BOOL)isTopSection {
    MNIConfigSectionsInfoModel *sectionsInfo = [[[MNIServerConfigManager sharedManager] serverConfigModel] sections_info];
    return [self.section_id isEqualToString:sectionsInfo.multisection.top_story_section_id] &&
    [self.name isEqualToString:MNITopSectionName];
}

// 2016.03.07 sferwerda - removed funky isEqual testing, we don't need it in Phoenix
//-(BOOL)isEqual:(id)object
//{
//    if (self == object) {
//        return YES;
//    }
//    
//    if ([object isKindOfClass:[MISectionModel class]]) {
//        return [self isEqualToSection:(MISectionModel *)object];
//    }
//    else if([object isKindOfClass:[MIConfigSectionModel class]])
//    {
//        return [self isEqualToConfigSection:(MIConfigSectionModel *)object];
//    }
//    
//    return NO;
//}
//
//- (BOOL)isEqualToSection:(MISectionModel *)section
//{
//    if(![[self url] isEqual:section.url] && self.url)
//    {
//        return NO;
//    }
//    else if(self.url)
//    {
//        return YES;
//    }
//    
//    if(![[self name] isEqualToString:section.title] && self.name)
//    {
//        return NO;
//    }
//    
//    return YES;
//}
//
//-(BOOL)isEqualToConfigSection:(MIConfigSectionModel *)section
//{
//    if(![[self url] isEqual:section.url] && self.url)
//    {
//        return NO;
//    }
//    else if(self.url)
//    {
//        return YES;
//    }
//    
//    if(![[self name] isEqualToString:section.name] && self.name)
//    {
//        return NO;
//    }
//    
//    return YES;
//}

@end

#pragma mark - More Options

@implementation MNIConfigMoreOptionsModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name": @"name",
             @"type": @"type",
             @"url": @"url",
             @"more_options": @"more_options"
             };
}

+ (NSValueTransformer *)typeJSONTransformer {
    NSDictionary *mapping = @{
                              @"weather": @(MNIMoreOptionTypeWeather),
                              @"label": @(MNIMoreOptionTypeLabel),
                              @"internal_link": @(MNIMoreOptionTypeInternalLink),
                              @"external_link": @(MNIMoreOptionTypeExternalLink),
                              @"print_edition": @(MNIMoreOptionTypePrintEdition),
                              @"settings": @(MNIMoreOptionTypeSettings),
                              };
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:mapping];
}

+ (NSValueTransformer *)more_optionsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIConfigMoreOptionsModel class]];
}

@end

#pragma mark - Ads

@implementation MNIConfigAdsAdhesionModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             // FIXME: checking the user interface idiom here prevents proper support for iOS 9 multitasking
             @"size": UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"tablet.size" : @"phone.size"
             };
}

+ (NSValueTransformer *)sizeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *sizeDictionary, BOOL *success, NSError *__autoreleasing *error) {
        return [NSValue valueWithCGSize:CGSizeMake([sizeDictionary[@"width"] floatValue], [sizeDictionary[@"height"] floatValue])];
    }];
}

@end

@implementation MNIConfigAdsinterstitialModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"thresholdForSections": @"thresholds.sections",
             @"thresholdForStories": @"thresholds.stories",
             @"thresholdForGalleries": @"thresholds.galleries",
             @"thresholdForVideos" : @"thresholds.videos"
             };
}

@end

@implementation MNIConfigAdsAdmobPageLevelModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"section": @"section",
             @"story" : @"story"
             };
}

@end

@implementation MNIConfigAdsAdmobModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"test_devices": @"test_devices",
             // FIXME: checking the user interface idiom here prevents proper support for iOS 9 multitasking
             @"ad_unit_id" : UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"tablet.ad_unit_id" : @"phone.ad_unit_id",
             @"pl" : @"pl"
             };
}

@end

@implementation MNIConfigAdsMSSFAdDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"pkg": @"pkg",
             @"placement_url" : @"placement_url"
             };
}

@end

@implementation MNIConfigAdsMSSFModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"device": @"device",
             @"position": @"position",
             @"type": @"type",
             @"ad_data" : @"ad_data"
             };
}

+ (NSValueTransformer *)typeJSONTransformer {
    NSDictionary *mapping = @{
                              @"banner": @(MNIAdTypeBanner),
                              @"native": @(MNIAdTypeNative)
                              };
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:mapping];
}

+ (NSValueTransformer *)positionJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id dictobject, BOOL *success, NSError *__autoreleasing *error) {
        if ([dictobject isKindOfClass:[NSString class]]) {
            return [NSNumber numberWithInteger:[((NSString *)dictobject) integerValue]];
        }
        else {
            return @0;
        }
    } reverseBlock:^id(NSNumber *anum, BOOL *success, NSError *__autoreleasing *error) {
        return anum.stringValue;
    }];
}

@end

@implementation MNIConfigAdsModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"enabled": @"enabled",
             @"menu_enabled": @"menu_enabled",
             @"adhesion": @"adhesion",
             @"interstitial" : @"interstitial",
             @"admob" : @"admob",
             @"mssf" : @"mssf"
             };
}

+ (NSValueTransformer *)mssfJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *adDictionary, BOOL *success, NSError *__autoreleasing *error) {
        
        NSMutableDictionary *transformedDictionary = [NSMutableDictionary dictionaryWithDictionary:adDictionary];
        
        NSArray *keys = [adDictionary allKeys];
        for (NSString *key in keys) {
            NSMutableArray *transformedArray = [NSMutableArray new];
            for (NSDictionary *dict in adDictionary[key]) {
                NSError *error;
                MNIConfigAdsMSSFModel *ad = [MTLJSONAdapter modelOfClass:[MNIConfigAdsMSSFModel class] fromJSONDictionary:dict error:&error];
                if (error == nil)
                    [transformedArray addObject:ad];
            }
            [transformedDictionary setObject:transformedArray forKeyedSubscript:key];
        }
        
        return transformedDictionary;
        
    }];
}

@end

#pragma mark - Market Timezone

@implementation MNIConfigMarketTimezoneModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"abbreviation": @"abbreviation",
             @"offset": @"offset"
             };
}

@end

#pragma mark - MSSF Info
@implementation MNIConfigMultiSectionsModel
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"top_stories_shown": @"top_stories_shown",
             @"top_story_section_id": @"top_story_section_id",
             @"sections_shown" : @"sections_shown",
             @"stories_shown" : @"stories_shown"
             };
}
@end

#pragma mark - Sections Info

@implementation MNIConfigSectionsInfoModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"stories_shown_per_section": @"stories_shown_per_section",
             @"multisection": @"multisection",
             @"sections" : @"sections"
             };
}

+ (NSValueTransformer *)sectionsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIConfigSectionModel class]];
}

- (MNIConfigSectionModel *)modelForSectionWithID:(NSString *)sectionID
{
    MNIConfigSectionModel *result = nil;
    if (sectionID.length > 0) {
        NSInteger i = [self.sections indexOfObjectPassingTest:^BOOL(MNIConfigSectionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [sectionID isEqualToString:obj.section_id];
        }];
        if (i != NSNotFound) result = self.sections[i];
    }
    return result;
}

@end


#pragma mark - Root

@implementation MNIServerConfigModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"market_timezone": @"market_timezone",
             @"app_store_id": @"app_store_id",
             @"alerts": @"alerts",
             @"weather" : @"weather",
             @"paywall" : @"paywall",
             @"push_notifications" : @"push_notifications",
             @"analytics" : @"analytics",
             @"about" : @"about",
             @"video" : @"video",
             @"social" : @"social",
             @"sections_info" : @"sections_info",
             @"more_options" : @"more_options",
             @"ads" : @"ads",
             @"apiInfo" : @"api_info"
             };
}

+ (NSValueTransformer *)alertsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIConfigAlertModel class]];
}

+ (NSValueTransformer *)more_optionsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIConfigMoreOptionsModel class]];
}

- (MNIConfigSectionModel *)sectionModelWithID:(NSString *)sectionID
{
    return [self sectionModelWithID:sectionID inArray:self.sections_info.sections searchRecursively:NO];
}

- (MNIConfigSectionModel *)sectionModelWithID:(NSString *)sectionID inArray:(NSArray<MNIConfigSectionModel *> *)sections searchRecursively:(BOOL)shouldRecurse
{
    MNIConfigSectionModel *result = nil;
    NSUInteger matchIndex = [sections indexOfObjectPassingTest:^BOOL(MNIConfigSectionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.section_id isEqualToString:sectionID];
    }];
    
    if (matchIndex != NSNotFound) {
        result = sections[matchIndex];
    }
    else {
        if (shouldRecurse) {
            for (MNIConfigSectionModel *aSectionModel in sections) {
                if (aSectionModel.sections.count > 0) {
                    result = [self sectionModelWithID:sectionID inArray:aSectionModel.sections searchRecursively:shouldRecurse];
                    if (result != nil) break;
                }
            }
        }
    }
    
    return result;
}

@end
