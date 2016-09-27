//
//  MNIStory.h
//  
//
//  Created by Yann Duran on 3/14/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MNIStoryModel.h"

@class MNISection;

NS_ASSUME_NONNULL_BEGIN

@interface MNIStory : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
- (MNIStoryModel*)modelObjectForStoryContent;

@end

@interface MNIStoryContentTransformation : NSValueTransformer

@end


NS_ASSUME_NONNULL_END

#import "MNIStory+CoreDataProperties.h"
