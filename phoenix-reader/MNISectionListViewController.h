//
//  MNISectionListViewController.h
//  phoenix-reader
//
//  Created by Scott Ferwerda on 5/9/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNIServerConfigModels.h"
#import "MNISectionListOtherOptionsCell.h"


@class MNISectionListViewController;

@protocol MNISectionListViewDelegate <NSObject>

- (void)mniSectionList:(nonnull MNISectionListViewController *)sectionListVC didSelectSection:(nullable MNIConfigSectionModel *)selectedItem;
- (void)mniSectionList:(nonnull MNISectionListViewController *)sectionListVC didSelectOtherOption:(nullable MNIConfigMoreOptionsModel *)selectedItem;

@end

@interface MNISectionListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MNISectionListOtherOptionsCellDelegate>

@property (strong, nonatomic, nullable) NSString *currentSelectedSectionID;

@property (weak, nonatomic, nullable) id<MNISectionListViewDelegate> sectionListViewDelegate;

@end
