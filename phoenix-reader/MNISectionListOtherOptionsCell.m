//
//  MNISectionListOtherOptionsCell.m
//  phoenix-reader
//
//  Created by Scott Ferwerda on 5/27/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNISectionListOtherOptionsCell.h"

@interface MNISectionListOtherOptionsCell ()

- (IBAction)buttonTouched:(id)sender;

@end

@implementation MNISectionListOtherOptionsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _delegate = nil;
    // Initialization code
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _delegate = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonTouched:(id)sender {
    UIButton *sendingButton = (UIButton *)sender;
    if (self.delegate != nil) {
        [self.delegate sectionListOtherOptionsCell:self didSelectOtherOptionWithIndex:sendingButton.tag];
    }
}

@end
