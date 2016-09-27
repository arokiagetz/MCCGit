//
//  MNIGradientView.m
//  phoenix-reader
//
//  Created by Karthika on 29/08/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNIGradientView.h"

@implementation MNIGradientView
@dynamic layer;

+ (Class)layerClass {
    return [CAGradientLayer class];
}
@end
