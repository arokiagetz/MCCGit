//
//  MNIThemeManager.m
//  phoenix-reader
//
//  Created by Karthika on 02/08/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNIThemeManager.h"
#import "MNIUITheme.h"
#import "UIColor+ColorHelpers.h"
#import "RootSplitViewController.h"
#import "MNIMasterViewNavigationController.h"
#import "MNISectionFrontViewController.h"
#import "MNIPageViewController.h"
#define kMNIUITheamKey          @"MNIUITheme"

#define MNIDarkThemeTintColor           [UIColor blackColor]
#define MNILightThemeTintColor          [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1]

#define MNILightThemeBackgroundColor    [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1]
#define MNIDarkThemeBackgroundColor     [UIColor colorWithRed:106.0/255.0 green:106.0/255.0 blue:106.0/255.0 alpha:1]


@interface MNIThemeManager ()



@end

@implementation MNIThemeManager

@synthesize isLightTheme = _isLightTheme;
@synthesize barStyle = _barStyle;
@synthesize tintColor = _tintColor;
@synthesize backgroundColor = _backgroundColor;
@synthesize barTintColor = _barTintColor;
@synthesize mastHeadImage = _mastHeadImage;
@synthesize sectionListImage = _sectionListImage;
@synthesize hollowCommandImage = _hollowCommandImage;
@synthesize solidCommandImage = _solidCommandImage;

+ (id) sharedThemeManager {
    static dispatch_once_t pred = 0;
    static id _sharedThemeManager = nil;
    dispatch_once(&pred, ^{
        _sharedThemeManager = [[self alloc] init];
    });
    return _sharedThemeManager;
}

- (void)checkForSavedTheme {
    
    NSString *themeValue = [[NSUserDefaults standardUserDefaults] valueForKey:kMNIUITheamKey];
    if (!themeValue) {
        [self saveLightTheme:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone];
    }
    [self applyThemeWithChange:NO];
}

- (void)saveLightTheme:(BOOL)isLIghtTheam {
    if (isLIghtTheam) {
        [[NSUserDefaults standardUserDefaults] setValue:MNIUIThemeNameStandardLight forKey:kMNIUITheamKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:MNIUIThemeNameStandardDark forKey:kMNIUITheamKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)changeTheme {
    [self setPropertiesNil];
    NSString *themeValue = [[NSUserDefaults standardUserDefaults] valueForKey:kMNIUITheamKey];
    [self saveLightTheme:![themeValue isEqualToString:MNIUIThemeNameStandardLight]];
}

- (NSString*) getTheme {
    /*get theme for iPhone and iPad*/
    return [[NSUserDefaults standardUserDefaults] valueForKey:kMNIUITheamKey];
}

- (void)applyTheme {
    [self applyThemeWithChange:YES];
}


- (void)applyThemeWithChange:(BOOL)isThemeChange {
    
    if (isThemeChange) {
        [self changeTheme];
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    UIWindow *window = [[application delegate] window];
    
    application.statusBarStyle = self.isLightTheme ? 0 : 1;
    
    [[UIRefreshControl appearance] setTintColor:self.tintColor];
    
    RootSplitViewController *splitVC = (RootSplitViewController*)window.rootViewController;
    
    if ([splitVC isKindOfClass:[UISplitViewController class]]) {
        [splitVC setNeedsStatusBarAppearanceUpdate];
        for (UINavigationController *navVc in splitVC.viewControllers) {
            if ([navVc isKindOfClass:[UINavigationController class]]) {
                if ([navVc isMemberOfClass:[MNIMasterViewNavigationController class]]) {
                    MNIMasterViewNavigationController *masterNavVC = (MNIMasterViewNavigationController*)navVc;
                    for (UIViewController *sectionVC in masterNavVC.viewControllers) {
                        if ([sectionVC isMemberOfClass:[MNISectionFrontViewController class]]) {
                            MNISectionFrontViewController *sectionFrontVC = (MNISectionFrontViewController*)sectionVC;
                            [sectionFrontVC setUpSelectedThemeForceUpdate:YES];
                            MNISuperSectionViewController *sectionPageVC = [sectionFrontVC.pageViewController.viewControllers firstObject];
                            [sectionPageVC setUpSelectedThemeForceUpdate:YES];
                        }
                    }
                    [masterNavVC.mastheadButton setImage:self.mastHeadImage forState:UIControlStateNormal];
                }
                else
                {
                    for (UIViewController *detailViewController in navVc.viewControllers) {
                        if ([detailViewController isMemberOfClass:[MNIPageViewController class]]) {
                            MNIPageViewController *pageViewController = (MNIPageViewController*)detailViewController;
                            [pageViewController.fbCommentButton setTitleColor:self.barTintColor forState:UIControlStateNormal];

                            if(!pageViewController.fbCommentButton || [pageViewController.fbCommentButton.titleLabel.text isEqualToString:@""]){
                                [pageViewController.fbCommentButton setImage:self.hollowCommandImage forState:UIControlStateNormal];
                            }
                            else {
                                [pageViewController.fbCommentButton setImage:self.solidCommandImage forState:UIControlStateNormal];
                            }
                            
                        }
                    }
                }
                [[navVc navigationBar] setTintColor:self.tintColor];
                [[navVc navigationBar] setBarTintColor:self.barTintColor];
            }
        }
    }
}

- (BOOL)isLightTheme {
    if (!_isLightTheme) {
        _isLightTheme = [[self getTheme] isEqualToString:MNIUIThemeNameStandardLight];
    }
    return _isLightTheme;
}

- (UIBarStyle)barStyle {
    if (!_barStyle) {
        _barStyle = self.isLightTheme ? UIBarStyleDefault : UIBarStyleBlack;
    }
    return _barStyle;
}

- (UIColor*)tintColor {
    if (!_tintColor) {
        _tintColor = self.isLightTheme ? MNIDarkThemeTintColor : MNILightThemeTintColor;
    }
    return _tintColor;
}

- (UIColor*)barTintColor {
    if (!_barTintColor) {
        _barTintColor = self.isLightTheme ? MNILightThemeTintColor : MNIDarkThemeTintColor;
    }
    return _barTintColor;
}

- (UIImage*)mastHeadImage {
    if (!_mastHeadImage) {
        _mastHeadImage = self.isLightTheme ?  [UIImage imageNamed:@"masthead"] : [UIImage imageNamed:@"mastheadwhite"];
    }
    return _mastHeadImage;
}

- (UIImage*)sectionListImage {
    if (!_sectionListImage) {
        _sectionListImage = self.isLightTheme ?  [UIImage imageNamed:@"Sectionlist"] : [UIImage imageNamed:@"Sectionlistwht"];
    }
    return _sectionListImage;
}

- (UIImage*)hollowCommandImage {
    if (!_hollowCommandImage) {
        _hollowCommandImage = self.isLightTheme ?  [UIImage imageNamed:@"hollowCommentDark"] : [UIImage imageNamed:@"hollowCommentWhite"];
    }
    return _hollowCommandImage;
}

- (UIImage*)solidCommandImage {
    if (!_solidCommandImage) {
        _solidCommandImage = self.isLightTheme ?  [UIImage imageNamed:@"solidCommentDark"] : [UIImage imageNamed:@"solidCommentWhite"];
    }
    return _solidCommandImage;
}

- (UIColor*)backgroundColor {
    if (!_backgroundColor) {
        _backgroundColor = self.isLightTheme ? MNILightThemeBackgroundColor : MNIDarkThemeBackgroundColor;
    }
    return _backgroundColor;
}

- (void)setPropertiesNil {
    _isLightTheme = NO;
    _barStyle = 0;
    _tintColor = nil;
    _barTintColor = nil;
    _mastHeadImage = nil;
    _sectionListImage = nil;
    _backgroundColor = nil;
    _hollowCommandImage = nil;
    _solidCommandImage = nil;
}

@end
