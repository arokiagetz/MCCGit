//
//  MNIStoryCellViewModel.m
//  phoenix-reader
//
//  Created by Sarat Chandran on 4/7/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNIStoryCellViewModel.h"
#import "NSDate+helper.h"

@interface MNIStoryCellViewModel()

@property (nonatomic, strong) NSString* publishedDateDisplay;

@end

@implementation MNIStoryCellViewModel

- (void) setPublishedDate:(NSDate *)publishedDate {
    [self setPublishedDate:publishedDate referenceDate:[NSDate date]];
}

- (void) setPublishedDate:(NSDate *)publishedDate referenceDate : (nonnull NSDate *)referenceDate {
    if (_publishedDate != publishedDate) {
        _publishedDate = publishedDate;
        _publishedDateDisplay = [NSDate MNITimeAgoSinceDate:publishedDate referenceDate:referenceDate];
    }
}

@end
