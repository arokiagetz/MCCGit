//
//  MNISuperSectionViewController.m
//  phoenix-reader
//
//  Created by SANDEEP on 9/8/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNISuperSectionViewController.h"
#import "MNIThemeManager.h"

@interface MNISuperSectionViewController ()

@end

@implementation MNISuperSectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setUpSelectedThemeForceUpdate:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpSelectedThemeForceUpdate:(BOOL)isForceUpdate {
    
    MNIThemeManager *themeManager = [MNIThemeManager sharedThemeManager];
    [self.tableView setBackgroundColor:themeManager.backgroundColor];
    [self.refreshControl setTintColor:themeManager.tintColor];
    
    if (isForceUpdate) {
        [self.tableView reloadData];
    }
}

@end
