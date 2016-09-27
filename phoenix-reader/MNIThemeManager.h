//
//  MNIThemeManager.h
//  phoenix-reader
//
//  Created by Karthika on 02/08/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MNIThemeManager : NSObject


@property (nonatomic, strong, readonly) UIColor *tintColor;
@property (nonatomic, strong, readonly) UIColor *barTintColor;
@property (nonatomic, strong, readonly) UIColor *backgroundColor;

@property (nonatomic, strong, readonly) UIImage *mastHeadImage;
@property (nonatomic, strong, readonly) UIImage *sectionListImage;
@property (nonatomic, strong, readonly) UIImage *hollowCommandImage;
@property (nonatomic, strong, readonly) UIImage *solidCommandImage;
@property (nonatomic, assign, readonly) UIBarStyle barStyle;
@property (nonatomic, assign, readonly) BOOL isLightTheme;

+ (id) sharedThemeManager;

- (NSString*)getTheme;
- (void)applyTheme;
- (void)checkForSavedTheme;
- (UIColor*)tintColor;
- (UIColor*)barTintColor;

@end
