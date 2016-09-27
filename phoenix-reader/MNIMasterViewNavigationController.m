//
//  MNIMasterViewNavigationController.m
//  phoenix-reader
//
//  Created by Scott Ferwerda on 6/9/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNIMasterViewNavigationController.h"
#import "MNISectionFrontViewController.h"
#import "UIColor+ColorHelpers.h"
#import "MNIThemeManager.h"
#import "MNIUITheme.h"
#define MASTHEAD_BUTTON_WIDTH 160.0
#define MASTHEAD_BUTTON_HEIGHT 22.0

@interface MNIMasterViewNavigationController ()

@end

@implementation MNIMasterViewNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set ourselves as delegate so we can handle showing/hiding the masthead button
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    BOOL showMasthead = [viewController isKindOfClass:[MNISectionFrontViewController class]];

    if (showMasthead) {
        // MOBI-2466 - feature/2466-masthead_home_button
        UIImage *mastheadIcon = [[MNIThemeManager sharedThemeManager] mastHeadImage];
        self.mastheadButton = [[UIButton alloc] init];
        self.mastheadButton.frame = CGRectMake( 0, 0, MASTHEAD_BUTTON_WIDTH, MASTHEAD_BUTTON_HEIGHT);
        [self.mastheadButton setImage:mastheadIcon forState:UIControlStateNormal];
        [self.mastheadButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.mastheadButton addTarget:self action:@selector(mastheadButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *mastheadBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.mastheadButton];
        [viewController.navigationItem setLeftBarButtonItem:mastheadBarButton];
   }
}

- (void)mastheadButtonSelected:(id)sender {
    if ([self.viewControllers[0] isKindOfClass:[MNISectionFrontViewController class]]) {
        MNISectionFrontViewController *sectionFront = (MNISectionFrontViewController*)self.viewControllers[0];
        MNISuperSectionViewController *childVC = sectionFront.pageViewController.viewControllers[0];
        if (childVC.pageIndex != 0) {
            MNISuperSectionViewController *nextChildVC = [sectionFront.sectionPageViewModel sectionTableViewControllerAtIndex:0];
            [sectionFront.pageViewController setViewControllers:@[nextChildVC] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
            [sectionFront.sectionPageViewModel.delegate sectionHeaderSelection:nextChildVC.pageIndex];
        }
    }
}

@end
