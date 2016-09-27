//
//  MNIGradientImageView.m
//  phoenix-reader
//
//  Created by Scott Ferwerda on 5/2/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNIGradientImageView.h"

@implementation MNIGradientImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupGradientLayer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupGradientLayer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupGradientLayer];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        [self setupGradientLayer];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self) {
        [self setupGradientLayer];
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    
    if (layer == self.layer) {
        self.gradientLayer.frame = self.bounds;
    }
}

- (void)setupGradientLayer
{
    self.gradientLayer = [CAGradientLayer layer];
    
    self.gradientLayer.frame = self.bounds;
    
    [self.layer addSublayer:self.gradientLayer];

}

@end
