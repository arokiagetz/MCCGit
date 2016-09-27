//
//  MNIPageViewController.h
//  phoenix-reader
//
//  Created by Sandeep on 7/12/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNIPageViewController : UIPageViewController

@property (nonnull, strong, nonatomic) NSArray *stories;
@property (nonatomic) int currentIndex;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bookMark;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *chat;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *share;
@property (nonnull,nonatomic, strong) UIButton *fbCommentButton;
@property (assign, nonatomic) BOOL fromPushMessage;

-(void)showHideBarButtonItemDisplay;
@end
