//
//  MNIStoryModel.m
//  phoenix-reader
//
//  Created by Yann Duran on 3/11/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNIStoryModel.h"
#import "NSDate+helper.h"

#pragma mark - leadtext

@implementation MNIStoryLeadtextModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"text" : @"text"
             };
}

@end

#pragma mark - embeds

@implementation MNIStoryEmbedModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"id" : @"id",
             @"value" : @"value"
             };
}

@end

#pragma mark - highlines

@implementation MNIStoryHighlineQuotesModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"author" : @"author",
             @"id" : @"id",
             @"text" : @"text"
             };
}

@end

@implementation MNIStoryHighlineNumberSetModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"desc" : @"desc",
             @"value" : @"value"
             };
}

@end

@implementation MNIStoryHighlineNumberModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"id" : @"id",
             @"set" : @"set"
             };
}

+ (NSValueTransformer *)setJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIStoryHighlineNumberSetModel class]];
}

@end

@implementation MNIStoryHighlineFactoidsModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"id" : @"id",
             @"text" : @"text"
             };
}

@end

#pragma mark - assets

@implementation MNIStoryAssetsModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"inlineAssets" : @"inline",
             @"leadAssets" : @"lead",
             @"relatedAssets" : @"related"
             };
}

+ (NSValueTransformer *)inlineAssetsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIStoryModel class]];
}

+ (NSValueTransformer *)leadAssetsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIStoryModel class]];
}

+ (NSValueTransformer *)relatedAssetsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIStoryModel class]];
}

@end

@implementation MNIStoryAssetsSource

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"mime_type" : @"mime_type",
             @"mrid" : @"mrid",
             @"uri" : @"uri",
             @"size" : @[@"width",@"height"]
             };
}

+ (NSValueTransformer *)sizeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *sizeDictionary, BOOL *success, NSError *__autoreleasing *error) {
        return [NSValue valueWithCGSize:CGSizeMake([sizeDictionary[@"width"] floatValue], [sizeDictionary[@"height"] floatValue])];
    }];
}

@end

@implementation MNIStoryAssetsAd

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"cust_params" : @"cust_params",
             @"lang" : @"lang",
             @"publication" : @"publication",
             @"sz" : @"sz",
             @"tag" : @"tag",
             @"vpos" : @"vpos"
             };
}

@end

#pragma mark - root

@implementation MNIStoryModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"ads" : @"ads",
             @"alt" : @"alt",
             @"asset_type" : @"asset_type",
             @"assets" : @"assets",
             @"author" : @"author",
             @"caption" : @"caption",
             @"content" : @"content",
             @"credit" : @"credit",
             @"dateline" : @"dateline",
             @"duration" : @"duration",
             @"embeds" : @"embeds", 
             @"gallery_photos" : @"gallery_photos",
             @"highline_factoids" : @"highline_factoids",
             @"highline_number_sets" : @"highline_number_sets",
             @"highline_quotes" : @"highline_quotes",
             @"home" : @"home",
             @"href" : @"href",
             @"id" : @"id",
             @"leadtext" : @"leadtext",
             @"media_id" : @"media_id",
             @"modified_date" : @"modified_date",
             @"overline" : @"overline",
             @"photographer" : @"photographer",
             @"publication" : @"publication",
             @"published_date" : @"published_date",
             @"sources" : @"sources",
             @"size" : @[@"width",@"height"],
             @"sub_headline" : @"sub_headline",
             @"summary" : @"summary",
             @"thumbnail" : @"thumbnail",
             @"title" : @"title",
             @"topic" : @"topic",
             @"url" : @"url",
             @"videographer" : @"videographer"
             };
}

+ (NSValueTransformer *)adsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIStoryAssetsAd class]];
}

+ (NSValueTransformer *)embedsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIStoryEmbedModel class]];
}

+ (NSValueTransformer *)gallery_photosJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIStoryModel class]];
}


+ (NSValueTransformer *)highline_factoidsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIStoryHighlineFactoidsModel class]];
}

+ (NSValueTransformer *)highline_number_setsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIStoryHighlineNumberModel class]];
}

+ (NSValueTransformer *)highline_quotesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIStoryHighlineQuotesModel class]];
}

+ (NSValueTransformer *)leadtextJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIStoryLeadtextModel class]];
}

+ (NSValueTransformer *)sourcesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MNIStoryAssetsSource class]];
}

+ (NSValueTransformer *)sizeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *sizeDictionary, BOOL *success, NSError *__autoreleasing *error) {
        return [NSValue valueWithCGSize:CGSizeMake([sizeDictionary[@"width"] floatValue], [sizeDictionary[@"height"] floatValue])];
    }];
}

+ (NSValueTransformer *)published_dateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *date, BOOL *success, NSError *__autoreleasing *error) {
        return [NSDate NSDateFromUnixTimestamp:date];
    }];
}

+ (NSValueTransformer *)modified_dateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *date, BOOL *success, NSError *__autoreleasing *error) {
        return [NSDate NSDateFromUnixTimestamp:date];
    }];
}


@end
