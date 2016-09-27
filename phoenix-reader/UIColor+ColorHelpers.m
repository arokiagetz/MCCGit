//
//  UIColor+ColorHelpers.m
//  Reader
//
//  Created by Stephen Deguglielmo on 9/9/15.
//  Copyright (c) 2015 McClatchy Interactive. All rights reserved.
//

#import "UIColor+ColorHelpers.h"

@implementation UIColor (ColorHelpers)

-(NSString *)hexValue
{
    CGFloat rFloat,gFloat,bFloat,aFloat;
    NSInteger r,g,b;
    [self getRed:&rFloat green:&gFloat blue:&bFloat alpha:&aFloat];
    
    r = (int)(255.0 * rFloat);
    g = (int)(255.0 * gFloat);
    b = (int)(255.0 * bFloat);
    
    return [NSString stringWithFormat:@"%02lx%02lx%02lx", (long)r, (long)g, (long)b];
}

+ (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha
{
    // Convert hex string to an integer
    unsigned int hexint = [self intFromHexString:hexStr];
    
    // Create color object, specifying alpha as well
    UIColor *color = [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                                     green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                                      blue:((CGFloat) (hexint & 0xFF))/255
                                     alpha:alpha];
    
    return color;
}

+ (UIColor *)colorWithRGBAString:(NSString *)rgbaStr
{
    // Convert hex string to an integer
    unsigned long hexint = [self intFromHexString:rgbaStr];
    
    // Create color object, specifying alpha as well
    UIColor *color = [UIColor colorWithRed:((hexint >> 24) & 0xFF) / 255.0
                                     green:((hexint >> 16) & 0xFF) / 255.0
                                      blue:((hexint >>  8) & 0xFF) / 255.0
                                     alpha:( hexint        & 0xFF) / 255.0];
    
    return color;
}

+ (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}


+ (UIColor *)headerViewBGColor:(BOOL)isiPhone {
    if (isiPhone) {
        return [[MNIThemeManager sharedThemeManager] isLightTheme] ? [UIColor blackColor] : [UIColor whiteColor];
    } else {
        return [UIColor darkGrayColor];
    }
    
    return nil;
}

+ (UIColor *) selectedMNIColor {
    return [UIColor colorWithRed:0.0/255.0 green:147.0/255.0 blue:208/255.0 alpha:1.0];
}
@end
