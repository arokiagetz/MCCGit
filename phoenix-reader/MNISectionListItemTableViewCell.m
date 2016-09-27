//
//  MNISectionListItemTableViewCell.m
//  phoenix-reader
//
//  Created by Scott Ferwerda on 5/10/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNISectionListItemTableViewCell.h"
#import "UIColor+ColorHelpers.h"
#import "MNIUITheme.h"

@interface MNISectionListItemTableViewCell ()

@property (strong, nonatomic) UIColor *normalBodyBackgroundColor;
@property (strong, nonatomic) UIColor *normalTitleTextColor;
@property (strong, nonatomic) UIColor *selectedBodyBackgroundColor;
@property (strong, nonatomic) UIColor *selectedTitleTextColor;

@end

@implementation MNISectionListItemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setColorScheme];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self setColorScheme];
}

- (void)setColorScheme
{
    NSString *normalBodyBackgroundHexColor;
    NSString *normalTitleTextHexColor;
    NSString *selectedBodyBackgroundHexColor;
    NSString *selectedTitleTextHexColor;
    
    // TODO: resolve these hard-coded theme colors with the flexible system in MNIBootstrapConfig - one solution or the other needs to be removed.
    if ([self.themeIdentifier isEqualToString:MNIUIThemeNameStandardLight]) {
//        normalBodyBackgroundHexColor = @"ffffffff";
//        normalTitleTextHexColor = @"000000ff";
        // this view should always be white-on-black, regardless of theme
        normalBodyBackgroundHexColor = @"000000ff";
        normalTitleTextHexColor = @"ffffffff";
    }
    else {
        normalBodyBackgroundHexColor = @"000000ff";
        normalTitleTextHexColor = @"ffffffff";
    }
    selectedBodyBackgroundHexColor = @"999999ff";
    selectedTitleTextHexColor = @"ffffffff";
    
    self.normalBodyBackgroundColor = [UIColor colorWithRGBAString:normalBodyBackgroundHexColor];
    self.normalTitleTextColor = [UIColor colorWithRGBAString:normalTitleTextHexColor];
    self.selectedBodyBackgroundColor = [UIColor colorWithRGBAString:selectedBodyBackgroundHexColor];
    self.selectedTitleTextColor = [UIColor colorWithRGBAString:selectedTitleTextHexColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    UIColor *bodyBackgroundColor = (selected ? self.selectedBodyBackgroundColor : self.normalBodyBackgroundColor);
    UIColor *titleTextColor = (selected ? self.selectedTitleTextColor : self.normalTitleTextColor);
    
    void (^animationsBlock)(MNISectionListItemTableViewCell *) = ^(MNISectionListItemTableViewCell *blockSelf) {
        self.backgroundColor = bodyBackgroundColor;
        self.titleLabel.textColor = titleTextColor;
    };
    
    // TODO: rather than always forcing an animation here, we should change the caller to request animation when appropriate
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            __weak MNISectionListItemTableViewCell *weakSelf = self;
            animationsBlock(weakSelf);
        }];
    }
    else {
        animationsBlock(self);
    }
}

@end
