//
//  MNIStoryCellViewModel.h
//  phoenix-reader
//
//  Created by Sarat Chandran on 4/7/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MNIStoryCellTypes
{
    MNIStandardStoryCell,
    MNITopStoryCell,
    MNIMSSFLeadStoryCell,
    MNIVideoStoryCell,
    MNIPictureStoryCell
} MNIStoryCellType;

@interface MNIStoryCellViewModel : NSObject

@property (nonatomic, assign) MNIStoryCellType storyCellType;
@property (nonatomic, strong) NSString* headline;
@property (nonatomic, strong) NSString* detail;
@property (nonatomic, strong) NSString* image;
@property (nonatomic, strong) NSString* section;
@property (nonatomic, strong) NSDate* publishedDate;
@property (nonatomic, readonly) NSString* publishedDateDisplay;

//added this method to make it testable
- (void) setPublishedDate:(NSDate *)publishedDate referenceDate : (nonnull NSDate *)referenceDate;

@end
