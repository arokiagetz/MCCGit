//
//  MNIHeaderView.m
//  phoenix-reader
//
//  Created by Yann Duran on 4/14/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNIHeaderView.h"
#import "UIColor+ColorHelpers.h"
@implementation MNIHeaderView

@synthesize dropDownButtonHidden = _dropDownButtonHidden;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"MNIHeaderView" owner:self options:nil];
        if ([arrayOfViews count] < 1)
            return nil;
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UIView class]])
            return nil;
        self = [arrayOfViews objectAtIndex:0];
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *view in self.subviews) {
        if ([view pointInside:[self convertPoint:point toView:view] withEvent:event]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - getters / setters

- (BOOL)dropDownButtonHidden
{
    return _dropDownButtonHidden;
}

- (void)setDropDownButtonHidden:(BOOL)dropDownButtonHidden
{
    _dropDownButtonHidden = dropDownButtonHidden;
    self.dropDownButton.hidden = _dropDownButtonHidden;
}


#pragma mark - IBActions

- (IBAction)titleTouched:(id)sender {
    if (self.dropDownButtonHidden == NO) {
        // dropdown is visible - treat this header touch the same
        [self dropDownTouched:sender];
    }
    else {
        // dropdown hidden - treat as header touch
        if (self.delegate != nil) {
            [self.delegate sectionHeaderTouchedForMNIHeaderView:self];
        }
    }
}

- (IBAction)dropDownTouched:(id)sender {
    if (self.dropDownButtonHidden == NO) {
        BOOL nowOpened = ! self.dropDownButton.selected;
        self.dropDownButton.selected = nowOpened;
        if (self.delegate != nil) {
            [self.delegate mniHeaderView:self didToggleDropDownButtonToOpened:nowOpened];
        }
    }
}

#pragma mark - public methods

- (void)setHeaderButtonTitle:(NSString *)title
{
    [self.headerButton setTitle:[title uppercaseString] forState:UIControlStateNormal];
    [self.headerButton sizeToFit];
   

}

- (void)setDropDownButtonToOpened:(BOOL)opened
{
    if (opened) {
        self.dropDownButton.selected = YES;
    }
    else {
        self.dropDownButton.selected = NO;
    }
}

@end
