//
//  MNISectionsPageViewModel.h
//  phoenix-reader
//
//  Created by Sandeep on 9/2/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MNISuperSectionViewController.h"

@protocol MNISectionTopTabViewDelegate <NSObject>

- (void)sectionHeaderSelection:(NSUInteger)pageIndex;

@end

@interface MNISectionsPageViewModel : NSObject <UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (strong, nonatomic) NSArray *sections;
@property (weak, nonatomic) id<MNISectionTopTabViewDelegate> delegate;

- (instancetype)initWithSections:(NSArray*)sections;
- (MNISuperSectionViewController *)sectionTableViewControllerAtIndex:(NSUInteger)index;

@end
