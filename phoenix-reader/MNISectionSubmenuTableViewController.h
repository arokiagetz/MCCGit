//
//  MNISectionSubmenuTableViewController.h
//  phoenix-reader
//
//  Created by Scott Ferwerda on 5/6/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNIServerConfigModels.h"
#import "MasterViewModels.h"


@class MNISectionSubmenuTableViewController;

@protocol MNISectionSubmenuDelegate <NSObject>

- (void)sectionSubmenu:(MNISectionSubmenuTableViewController *)sectionSubmenu didSelectSubsection:(MNIConfigSectionModel *)subSection;

@end

@interface MNISectionSubmenuTableViewController : UITableViewController

@property (strong, nonatomic) NSArray<MNIConfigSectionModel *> *subsections;
@property (strong, nonatomic) NSString *selectedSectionID;

@property (weak, nonatomic) id<MNISectionSubmenuDelegate> submenuDelegate;

@end
