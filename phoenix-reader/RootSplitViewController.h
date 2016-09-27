//
//  RootSplitViewController.h
//  phoenix-reader
//
//  Created by Yann Duran on 4/5/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootSplitViewController : UISplitViewController <UISplitViewControllerDelegate>

@property (assign, nonatomic) BOOL lockMasterView;

- (void)toggleMasterView;

@end
