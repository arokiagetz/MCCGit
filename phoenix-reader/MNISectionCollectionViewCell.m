//
//  MNISectionCollectionViewCell.m
//  phoenix-reader
//
//  Created by Sandeep on 9/1/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNISectionCollectionViewCell.h"
#import "UIColor+ColorHelpers.h"

@interface MNISectionCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *underLineImageView;

@end

@implementation MNISectionCollectionViewCell

#pragma mark - getters/setters

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        [self.underLineImageView setBackgroundColor:[UIColor selectedMNIColor]];
    } else {
        [self.underLineImageView setBackgroundColor:[UIColor clearColor]];
    }
    [self setTitleLabelTextColor:selected];
}

- (void)setSectionName:(NSString *)sectionName {
    [self.titleLabel setText:[sectionName uppercaseString]];
    [self setTitleLabelTextColor:self.selected];
}

- (void)setTitleLabelTextColor:(BOOL)selected {
    BOOL isLightTheme = [[MNIThemeManager sharedThemeManager] isLightTheme];
    NSString *rgbString = isLightTheme ? @"474747ff" : @"ffffffff";
    UIColor *textColor = selected ? [UIColor selectedMNIColor] : [UIColor colorWithRGBAString:rgbString];
    [self.titleLabel setTextColor:textColor];
}

@end

