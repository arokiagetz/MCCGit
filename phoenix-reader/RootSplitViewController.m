//
//  RootSplitViewController.m
//  phoenix-reader
//
//  Created by Yann Duran on 4/5/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "RootSplitViewController.h"
#import "MNIUITheme.h"
#import "MNIThemeManager.h"

@implementation RootSplitViewController

- (void)setupUI
{
    // Avoid hidden view to be presented and dismissed via a swipe gesture
    self.presentsWithGesture = NO;
    // Avoid different widths on portrait vs landscape ( yes I've seen this happening )
    self.minimumPrimaryColumnWidth = 320.0f;
    self.maximumPrimaryColumnWidth = 320.0f;
    // Who's your delegate?, you are!
    self.delegate = self;
    // Make sure we have the right display mode
    self.preferredDisplayMode = [self preferredDisplayModeForSize:self.view.frame.size];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self setTheme];
    [self toggleMasterView];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    self.preferredDisplayMode = [self preferredDisplayModeForSize:size];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    [super preferredStatusBarStyle];
    MNIThemeManager *themeManager = [MNIThemeManager sharedThemeManager];
    return themeManager.isLightTheme ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

#pragma mark <UISplitViewControllerDelegate>

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    // Let's return YES cause we always want to show the Master VC on Phone portait
    return YES;
}

#pragma mark -

// Helper method **IMPORTANT**
- (UISplitViewControllerDisplayMode)preferredDisplayModeForSize:(CGSize)size
{
    if (size.width > size.height)
        // Landscape
        return UISplitViewControllerDisplayModeAllVisible;
    else
        // Portrait
        if (self.lockMasterView) return UISplitViewControllerDisplayModePrimaryOverlay;
        else return UISplitViewControllerDisplayModeAutomatic;
}

// Simulate a tap on the display mode button
- (void)toggleMasterView
{
    if (self.preferredDisplayMode == UISplitViewControllerDisplayModeAllVisible)
        return;
    
    UIBarButtonItem *displayModeButtonItem = self.displayModeButtonItem;
    [[UIApplication sharedApplication] sendAction:displayModeButtonItem.action to:displayModeButtonItem.target from:nil forEvent:nil];
}
-(void)setTheme{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasBeenLaunched"]) {
        // show your only-one-time view
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasBeenLaunched"];
        
        NSUserDefaults *theme = [NSUserDefaults standardUserDefaults];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            [theme setObject:MNIUIThemeNameStandardLight forKey:@"iPhoneTheme"];
        }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            [theme setObject:MNIUIThemeNameStandardDark forKey:@"iPadTheme"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}
@end
