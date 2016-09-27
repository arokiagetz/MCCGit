//
//  UIColor+ColorHelpers.h
//  Reader
//
//  Created by Stephen Deguglielmo on 9/9/15.
//  Copyright (c) 2015 McClatchy Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNIUITheme.h"
#import "MNIThemeManager.h"
#import "MasterViewModels.h"

@interface UIColor (ColorHelpers)

-(NSString *)hexValue;

+ (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha;

+ (UIColor *)colorWithRGBAString:(NSString *)rgbaStr;

+ (UIColor *)headerViewBGColor:(BOOL)isiPhone;

+ (UIColor *) selectedMNIColor;

@end
