//
//  MNISectionSubmenuTableCell.m
//  phoenix-reader
//
//  Created by Scott Ferwerda on 5/6/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNISectionSubmenuTableCell.h"
#import "MNIUITheme.h"
#import "UIColor+ColorHelpers.h"


@implementation MNISectionSubmenuTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    // TODO: set colors on select/deselect
    UIColor *newBackgroundColor = [UIColor getUIColorObjectFromHexString:(selected ? MNIUIColor2020LightGray : MNIUIColor2020MediumGray) alpha:1.0];
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundColor = newBackgroundColor;
        }];
    }
    else {
        self.backgroundColor = newBackgroundColor;
    }
}

@end
