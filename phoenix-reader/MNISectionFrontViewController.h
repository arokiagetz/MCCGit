//
//  MNISectionFrontViewController.h
//  phoenix-reader
//
//  Created by Scott Ferwerda on 5/20/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MNIStoryManager.h"
#import "SectionPreferences.h"
#import "MNISectionListViewController.h"
#import "MNISectionFrontMoreStoriesCell.h"
#import "MNIHeaderView.h"
#import "MNISectionSubmenuTableViewController.h"
#import "MNISectionsPageViewModel.h"

#define MNIHomeSectionName NSLocalizedString(@"Home", nil)
#define MNIObitsMoreSectionName NSLocalizedString(@"Obits and More", nil)

@interface MNISectionFrontViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem*weatherButton;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) MNISectionsPageViewModel *sectionPageViewModel;
@property (assign, nonatomic) NSUInteger selectedSectionIndex;

- (void)setUpSelectedThemeForceUpdate:(BOOL)isForceUpdate;

@end
