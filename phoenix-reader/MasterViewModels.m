//
//  MasterViewModels.m
//  phoenix-reader
//
//  Created by Scott Ferwerda on 4/26/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MasterViewModels.h"
#import <BlocksKit/BlocksKit.h>
#import "MILog.h"
#import "MNISectionPreferencesHandler.h"
#import "MNIUITheme.h"
#import "MNISection.h"
#import "MNIGlobalConstants.h"

@implementation MasterViewModelItem

@end

@implementation MasterViewModelSection

- (NSInteger)indexOfSubsectionWithID:(NSString *)sectionID
{
    NSInteger result = [self.subsections indexOfObjectPassingTest:^BOOL(MNIConfigSectionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.section_id isEqualToString:sectionID];
    }];
    return result;
}

- (MNIConfigSectionModel *)subsectionWithID:(NSString *)sectionID
{
    MNIConfigSectionModel *result = nil;
    NSInteger i = [self indexOfSubsectionWithID:sectionID];
    if (i != NSNotFound) {
        result = self.subsections[i];
    }
    return result;
}

@end

@interface MasterViewModel ()

@end

@implementation MasterViewModel

@synthesize sections = _sections;

#pragma mark - public methods

- (instancetype)initWithSectionIDs:(nullable NSArray<MNIConfigSectionModel *> *)sections {
    self = [self init];
    if (self) {
        self.orderedSections = sections;
    }
    return self;
}

//- (MasterViewModelSection *)sectionWithID:(NSString *)sectionID
//{
//    MasterViewModelSection *result = nil;
//    NSInteger i = [self indexOfSectionWithID:sectionID];
//    if (i != NSNotFound) {
//        result = self.sections[i];
//    }
//    return result;
//}


- (void)rebuildViewModelWithSectionFetchedResult:(NSArray <MNISection *> *)sections {
    
    NSMutableArray<MasterViewModelSection *> *newSections = [[NSMutableArray alloc] init];
    for (MNISection *section in sections) {
        MasterViewModelSection *aVMSection = [self parseSectionModelFromSectionManageObject:section];
        [newSections addObject:aVMSection];
    }
    _sections = newSections;
}

- (MNIConfigSectionModel *)mapSectionConfigFormSection:(MNISection *)section {
    MNIConfigSectionsInfoModel *sectionInfo = [[[MNIServerConfigManager sharedManager] serverConfigModel] sections_info];
    MNIConfigSectionModel *sectionConfig = [sectionInfo.sections bk_match:^BOOL(MNIConfigSectionModel *sectionCon) {
        return [sectionCon.name isEqualToString:section.name] && [sectionCon.section_id isEqualToString:section.sectionID] && [sectionCon.contentType isEqualToString:section.contentType];
    }];
    if (!sectionConfig) {
        
    }
    return sectionConfig;
}

- (MasterViewModelSection *)parseSectionModelFromSectionManageObject:(MNISection *)sectionObject {
    
    MNIServerConfigModel *serverConfigModel = [[MNIServerConfigManager sharedManager] serverConfigModel];
    MNIConfigSectionsInfoModel *sectionInfo = [serverConfigModel sections_info];
    NSString *topStorySectionID = sectionInfo.multisection.top_story_section_id;
    
    MasterViewModelSection *aVMSection = [[MasterViewModelSection alloc] init];
    aVMSection.sectionName = sectionObject.name;
    aVMSection.isTopStoriesSection = [sectionObject.sectionID isEqualToString:topStorySectionID] && [sectionObject.name isEqualToString:MNITopSectionName];
    aVMSection.sectionType = MasterViewModelItemTypeNormal;
    aVMSection.sectionID = sectionObject.sectionID;
    aVMSection.isMainSection = [sectionObject.isMainSection boolValue];
    aVMSection.hasSubsections = [sectionObject.sections count] > 0;
    
    MNISection *tempSection = [sectionObject isMainSection] ? sectionObject : [[sectionObject.sections allObjects] firstObject];
    
    MNIConfigSectionModel *sectionConfig = [self mapSectionConfigFormSection:tempSection];
    aVMSection.subsections = sectionConfig.sections;
    aVMSection.mainSectionName = sectionConfig.name;
    aVMSection.sectionConfig = sectionConfig;
    
    NSMutableArray<MasterViewModelItem *> *newVMItems = [[NSMutableArray alloc] init];
    
    NSInteger topStoriesShown = sectionInfo.multisection.top_stories_shown;
    NSInteger storiesShown = [self isMultisectionViewModel] ? sectionInfo.multisection.stories_shown : sectionInfo.stories_shown_per_section;
    
    
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                        sortDescriptorWithKey:@"fetchedDate"
                                        ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    NSArray *storiesInSection = [[sectionObject.stories allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    
//    NSArray *storiesInSection = [sectionObject.stories allObjects];
    NSUInteger numStories;
    if ([self isMultisectionViewModel] && aVMSection.isTopStoriesSection) {
        numStories = MIN(storiesInSection.count, topStoriesShown);
    } else {
        numStories = MIN(storiesInSection.count, storiesShown);
    }
    
    for (NSInteger index = 0; index < numStories; index++) {
        MNIStory *story = storiesInSection[index];
        MasterViewModelItem *aVMItem = [self parseStoryFromStoryManagedObject:story atIndex:index isTopStorySection:aVMSection.isTopStoriesSection];
        [newVMItems addObject:aVMItem];
    }
    aVMSection.sectionItems = newVMItems;
    
    return aVMSection;
}


- (MasterViewModelItem *)parseStoryFromStoryManagedObject:(MNIStory *)aStory atIndex:(NSInteger)index isTopStorySection:(BOOL)isTopStoriesSection {
    MasterViewModelItem *aVMItem = [[MasterViewModelItem alloc] init];
    
    MNIStoryModel *aStoryModel = aStory.modelObjectForStoryContent;
    
    aVMItem.itemType = MasterViewModelItemTypeNormal;
    BOOL needsThumbnail = YES;
    if (isTopStoriesSection && index == 0) {
        // lead story in top stories section
        aVMItem.normalItemSubtype = MasterViewModelNormalItemTypeTopStory;
    } else if (index == 0) {
        // lead story in section
        aVMItem.normalItemSubtype = MasterViewModelNormalItemTypeSectionLeadStory;
    }
    else {
        // determine if this is a gallery or not
        NSArray<NSString *> *videoAssetTypes = @[ @"videoStory", @"videoFile", @"videoIngest" ];
        NSArray<NSString *> *photoAssetTypes = @[ @"gallery", @"picture" ];
        if ([videoAssetTypes containsObject:aStoryModel.asset_type]) {
            aVMItem.normalItemSubtype = MasterViewModelNormalItemTypeVideoGalleryStory;
        }
        else if ([photoAssetTypes containsObject:aStoryModel.asset_type]) {
            aVMItem.normalItemSubtype = MasterViewModelNormalItemTypePhotoGalleryStory;
        }
        else {
            needsThumbnail = YES;
            aVMItem.normalItemSubtype = MasterViewModelNormalItemTypeStory;
        }
    }
    aStoryModel.thumbnail = [self leadAssetFromStoryAssetsModel:aStoryModel.assets];
    // check for missing photo and revert
    
    if (needsThumbnail && (aStoryModel.thumbnail.length == 0)) {
        aVMItem.normalItemSubtype = MasterViewModelNormalItemTypeStory;
    }
    aVMItem.storyModel = aStoryModel;
    NSAssert(aStoryModel.title != nil, @"can't find config section with ID %@", aStoryModel.title);
    return aVMItem;
}



- (NSString*)leadAssetFromStoryAssetsModel:(MNIStoryAssetsModel*)assets {
    NSString *leadAssest;
    for (MNIStoryModel *storyModel in assets.leadAssets) {
        if ([storyModel.asset_type isEqualToString:@"picture"] && storyModel.thumbnail) {
            leadAssest = storyModel.thumbnail;
            break;
        }
    }
    return leadAssest;
}

- (NSArray<NSString *> *)homeSectionIDs
{
    MNIServerConfigModel *serverConfigModel = [[MNIServerConfigManager sharedManager] serverConfigModel];
    MNISectionPreferencesHandler *sectionPrefsHandler = [[MNISectionPreferencesHandler alloc] init];
    [sectionPrefsHandler updateWithServerConfigModel:serverConfigModel];
    NSMutableArray<NSString *> *newHomeSectionIDs = [[NSMutableArray alloc] init];
    NSError *error = nil;
    NSArray<NSString *> *preferredSectionIDOrder = [sectionPrefsHandler retrieveOrderedSectionIDsWithError:&error];
    if (error == nil) {
        NSInteger nIDs = MIN(preferredSectionIDOrder.count, serverConfigModel.sections_info.multisection.sections_shown);
        NSInteger iNew = 0;
        for (NSInteger iPrefs = 0; iPrefs < preferredSectionIDOrder.count; iPrefs++) {
            if ([preferredSectionIDOrder[iPrefs] isEqualToString:@"multisection"] == NO && [preferredSectionIDOrder[iPrefs] isEqualToString:serverConfigModel.sections_info.multisection.top_story_section_id] == NO) {
                [newHomeSectionIDs addObject:preferredSectionIDOrder[iPrefs]];
                iNew++;
                if (iNew >= nIDs) break;
            }
        }
    }
    else {
        MILogError(@"unexpected error getting home section ID's: %@", error);
    }
    
    return newHomeSectionIDs;
}

- (BOOL)isMultisectionViewModel {
    return (self.orderedSections.count > 1);
}


@end
