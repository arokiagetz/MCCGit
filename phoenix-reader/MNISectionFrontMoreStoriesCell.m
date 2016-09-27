//
//  MNISectionFrontMoreStoriesCell.m
//  phoenix-reader
//
//  Created by Scott Ferwerda on 4/12/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNISectionFrontMoreStoriesCell.h"

@implementation MNISectionFrontMoreStoriesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setBackgroundColor:[UIColor clearColor]];
    // Initialization code
}

- (void)prepareForReuse
{
    self.delegate = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)moreStoriesButtonTouched:(id)sender {
    if (self.delegate != nil) {
        [self.delegate buttonPressedInMoreStoriesCell:self];
    }
}

@end
