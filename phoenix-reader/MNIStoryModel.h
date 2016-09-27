//
//  MNIStoryModel.h
//  phoenix-reader
//
//  Created by Yann Duran on 3/11/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <Mantle/Mantle.h>

typedef NS_ENUM(NSUInteger, StoryAssetsModelNormalItemType)  {
    StoryAssetsModelNormalItemTypePhotoGalleryStory,
    StoryAssetsModelNormalItemTypeVideoGalleryStory,
};

#pragma mark - leadtext

@interface MNIStoryLeadtextModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *text;

@end

#pragma mark - embeds

@interface MNIStoryEmbedModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *value;

@end

#pragma mark - highlines

@interface MNIStoryHighlineQuotesModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *text;

@end

@interface MNIStoryHighlineNumberSetModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *value;

@end


@interface MNIStoryHighlineNumberModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSArray *set;

@end


@interface MNIStoryHighlineFactoidsModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *text;

@end

#pragma mark - assets

@interface MNIStoryAssetsModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSArray *inlineAssets;
@property (nonatomic, copy) NSArray *leadAssets;
@property (nonatomic, copy) NSArray *relatedAssets;

@end

@interface MNIStoryAssetsSource : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *mime_type;
@property (nonatomic, copy) NSString *mrid;
@property (nonatomic, copy) NSString *uri;
@property (nonatomic, assign) struct CGSize size;

@end

@interface MNIStoryAssetsAd : MTLModel <MTLJSONSerializing> // used on videos

@property (nonatomic, copy) NSString *cust_params;
@property (nonatomic, copy) NSString *lang;
@property (nonatomic, copy) NSString *publication;
@property (nonatomic, copy) NSString *sz;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *vpos;

@end

#pragma mark - root

@interface MNIStoryModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSArray *ads;
@property (nonatomic, copy) NSString *alt;
@property (nonatomic, copy) NSString *asset_type;
@property (nonatomic, copy) MNIStoryAssetsModel *assets;
@property (assign, nonatomic) StoryAssetsModelNormalItemType normalItemSubtype;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *credit;
@property (nonatomic, copy) NSString *dateline;
@property (nonatomic, copy) NSNumber *duration;
@property (nonatomic, copy) NSArray *embeds; 
@property (nonatomic, copy) NSArray *gallery_photos;
@property (nonatomic, copy) NSArray *highline_factoids;
@property (nonatomic, copy) NSArray *highline_number_sets;
@property (nonatomic, copy) NSArray *highline_quotes;
@property (nonatomic, copy) NSString *home;
@property (nonatomic, copy) NSString *href;
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *keywords;
@property (nonatomic, copy) NSArray *leadtext;
@property (nonatomic, copy) NSString *media_id;
@property (nonatomic, copy) NSDate *modified_date;
@property (nonatomic, copy) NSString *overline;
@property (nonatomic, copy) NSString *photographer;
@property (nonatomic, copy) NSString *publication;
@property (nonatomic, copy) NSDate *published_date;
@property (nonatomic, copy) NSArray *sources;
@property (nonatomic, assign) struct CGSize size;
@property (nonatomic, copy) NSString *sub_headline;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *topic;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *videographer;
@property (nonatomic,assign) NSInteger facebookCommentCount;

@end

