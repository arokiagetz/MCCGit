//
//  MNIStory+CoreDataProperties.h
//  phoenix-reader
//
//  Created by SANDEEP on 9/21/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MNIStory.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNIStory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *fetchedDate;
@property (nullable, nonatomic, retain) NSString *sectionId;
@property (nullable, nonatomic, retain) id storyContentTransformation;
@property (nullable, nonatomic, retain) NSString *storyId;
@property (nullable, nonatomic, retain) MNISection *section;

@end

NS_ASSUME_NONNULL_END
