//
//  MasterViewModels.h
//  phoenix-reader
//
//  Created by Scott Ferwerda on 4/26/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MNIServerConfigManager.h"
#import "MNIStory.h"

typedef NS_ENUM(NSUInteger, MasterViewModelItemType)  {
    MasterViewModelItemTypeUnknown = 0,
    MasterViewModelItemTypeNormal,
    MasterViewModelItemTypeBannerAd
};

typedef NS_ENUM(NSUInteger, MasterViewModelNormalItemType)  {
    MasterViewModelNormalItemTypeUnknown = 0,
    MasterViewModelNormalItemTypeStory,
    MasterViewModelNormalItemTypePhotoGalleryStory,
    MasterViewModelNormalItemTypeVideoGalleryStory,
    MasterViewModelNormalItemTypeTopStory,
    MasterViewModelNormalItemTypeSectionLeadStory,
};


@interface MasterViewModelItem : NSObject

@property (assign, nonatomic) MasterViewModelItemType itemType;
@property (assign, nonatomic) MasterViewModelNormalItemType normalItemSubtype;
@property (strong, nonatomic) MNIStoryModel *storyModel;
@property (assign, nonatomic) CGFloat cellHeight;

@end

typedef NS_ENUM(NSUInteger, MasterViewModelSectionType)  {
    MasterViewModelSectionTypeUnknown = 0,
    MasterViewModelSectionTypeNormal
};

@interface MasterViewModelSection : NSObject

@property (assign, nonatomic) MasterViewModelSectionType sectionType;
@property (strong, nonatomic) NSString *sectionID;
@property (strong, nonatomic) NSString *sectionName;
@property (strong, nonatomic) NSMutableArray<MasterViewModelItem *> *sectionItems;
@property (assign, nonatomic) BOOL hasMoreStories;
@property (assign, nonatomic) BOOL hasSubsections;
@property (strong, nonatomic) NSArray<MNIConfigSectionModel *> *subsections;
@property (strong, nonatomic) NSArray<MNIConfigSectionModel *> *parentSubsections;

@property (strong, nonatomic) NSString *parentSubsectionName;
@property (strong, nonatomic) NSString *mainSectionName;
@property (assign, nonatomic) BOOL isMainSection;
@property (strong, nonatomic) MNIConfigSectionModel *sectionConfig;

@property (assign, nonatomic) BOOL isTopStoriesSection;

- (NSInteger)indexOfSubsectionWithID:(NSString *)sectionID;
- (MNIConfigSectionModel *)subsectionWithID:(NSString *)sectionID;

@end

@interface MasterViewModel : NSObject

@property (strong, nonatomic, readonly) NSArray<MasterViewModelSection *> *sections; // holds arrays of sectional models
@property (strong, nonatomic) NSArray<MNIConfigSectionModel *> *orderedSections;
@property (strong, nonatomic) NSString *parentSectionId;


- (instancetype)initWithSectionIDs:(nullable NSArray<MNIConfigSectionModel *> *)sections;

- (void)rebuildViewModelWithSectionFetchedResult:(nonnull NSArray <MNISection *> *)sections;

- (nonnull NSArray<NSString *> *)homeSectionIDs;
- (BOOL)isMultisectionViewModel; // YES if this is a model for a multisection section front (e.g., the Home section)

@end