//
//  MNIStoryViewController.h
//  phoenix-reader
//
//  Created by Sandeep on 7/12/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterViewModels.h"

@protocol MNIStoryViewControllerDelegate <NSObject>

-(void)scrollToNextPage;
-(void)facebookCommentsCount:(NSInteger)commentsCount;

@end

@interface MNIStoryViewController : UIViewController

@property (assign, nonatomic) NSUInteger pageIndex;
@property (assign, nonatomic) MasterViewModelItem *storyModelItem;
@property (assign, nonatomic) MasterViewModelItem *nextStoryModelItem;
@property (assign, nonatomic) id <MNIStoryViewControllerDelegate> delegate;

@end
