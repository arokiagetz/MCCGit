//
//  MNIHeaderView.h
//  phoenix-reader
//
//  Created by Yann Duran on 4/14/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MNIHeaderView;

@protocol MNIHeaderViewDelegate <NSObject>

- (void)mniHeaderView:(nonnull MNIHeaderView *)headerView didToggleDropDownButtonToOpened:(BOOL)opened;
- (void)sectionHeaderTouchedForMNIHeaderView:(nonnull MNIHeaderView *)headerView;

@end

@interface MNIHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UIButton *headerButton;
@property (weak, nonatomic) IBOutlet UIButton *dropDownButton;

@property (assign, nonatomic) BOOL dropDownButtonHidden;
@property (weak, nonatomic) id<MNIHeaderViewDelegate> delegate;

- (IBAction)titleTouched:(id)sender;
- (IBAction)dropDownTouched:(id)sender;

- (void)setHeaderButtonTitle:(NSString *)title;

- (void)setDropDownButtonToOpened:(BOOL)opened;

@end
