//
//  MNISection+CoreDataProperties.h
//  phoenix-reader
//
//  Created by SANDEEP on 9/21/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MNISection.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNISection (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *contentType;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *sectionID;
@property (nullable, nonatomic, retain) NSNumber *sectionTemplate;
@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSDate *timeStamp;
@property (nullable, nonatomic, retain) NSNumber *sortOrder;
@property (nullable, nonatomic, retain) NSNumber *isMainSection;
@property (nullable, nonatomic, retain) NSSet<MNIStory *> *stories;
@property (nullable, nonatomic, retain) NSSet<MNISection *> *sections;

@end

@interface MNISection (CoreDataGeneratedAccessors)

- (void)addStoriesObject:(MNIStory *)value;
- (void)removeStoriesObject:(MNIStory *)value;
- (void)addStories:(NSSet<MNIStory *> *)values;
- (void)removeStories:(NSSet<MNIStory *> *)values;

- (void)addSectionsObject:(MNISection *)value;
- (void)removeSectionsObject:(MNISection *)value;
- (void)addSections:(NSSet<MNISection *> *)values;
- (void)removeSections:(NSSet<MNISection *> *)values;

@end

NS_ASSUME_NONNULL_END
