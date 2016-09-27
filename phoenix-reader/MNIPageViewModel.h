//
//  MNIPageViewModel.h
//  phoenix-reader
//
//  Created by Sandeep on 7/12/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MNIStoryViewController.h"

@class MNIPageViewController;

@interface MNIPageViewModel : NSObject <UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (strong, nonatomic) NSArray *stories;

- (instancetype)initWithStoris:(NSArray*)stories;
- (MNIStoryViewController *)storyViewControllerAtIndex:(NSUInteger)index;


@end
