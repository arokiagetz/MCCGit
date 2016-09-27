//
//  MNISectionFrontMoreStoriesCell.h
//  phoenix-reader
//
//  Created by Scott Ferwerda on 4/12/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MNISectionFrontMoreStoriesCell;

@protocol MNISectionFrontMoreStoriesCellDelegate <NSObject>

- (void)buttonPressedInMoreStoriesCell:(MNISectionFrontMoreStoriesCell *)cell;
@end

@interface MNISectionFrontMoreStoriesCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *moreStoriesButton;

@property (weak, nonatomic) id<MNISectionFrontMoreStoriesCellDelegate> delegate;

- (IBAction)moreStoriesButtonTouched:(id)sender;

@end
