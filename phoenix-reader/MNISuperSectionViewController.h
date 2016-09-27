//
//  MNISuperSectionViewController.h
//  phoenix-reader
//
//  Created by SANDEEP on 9/8/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNIServerConfigModels.h"


@class MNISectionViewController;

@protocol MNISectionViewControllerDelegate <NSObject>

- (void)sectionTableViewController:(MNISectionViewController *)sectionTableViewController moveToSectionWithSectionId:(NSString*)sectionId;

@end


@interface MNISuperSectionViewController : UIViewController

@property (assign, nonatomic) NSUInteger pageIndex;
@property (strong, nonatomic) MNIConfigSectionModel *sectionModel;
@property (weak, nonatomic) id<MNISectionViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

- (void)setUpSelectedThemeForceUpdate:(BOOL)isForceUpdate;

@end
