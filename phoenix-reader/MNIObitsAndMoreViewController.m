//
//  MNIObitsAndMoreViewController.m
//  phoenix-reader
//
//  Created by SANDEEP on 9/7/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNIObitsAndMoreViewController.h"
#import "MNIServerConfigModels.h"
#import "MNISectionListOtherOptionsCell.h"
#import "MNIServerConfigManager.h"
#import "MNIThemeManager.h"
#import "UIColor+ColorHelpers.h"
#import "MNIWebViewController.h"
#import "MILog.h"

static NSString * const MNISectionListOtherOptionsCellIdentifier = @"MNISectionListOtherOptionsCell";

@interface MNIObitsAndMoreViewController () <UITableViewDelegate, UITableViewDataSource, MNISectionListOtherOptionsCellDelegate>

@property (strong, nonatomic) NSArray<MNIConfigMoreOptionsModel *> *obitsMoreOptions;

@end

@implementation MNIObitsAndMoreViewController

#pragma mark - App Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setTableFooterView:[[UIView alloc] init]];
}

- (NSArray<MNIConfigMoreOptionsModel *> *)obitsMoreOptions {
    if (!_obitsMoreOptions) {
        MNIServerConfigModel *serverConfigModel = [[MNIServerConfigManager sharedManager] serverConfigModel];
        _obitsMoreOptions = [serverConfigModel more_options];
    }
    return _obitsMoreOptions;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numOtherOptions = self.obitsMoreOptions.count;
    NSInteger result = (numOtherOptions / 2);
    if (numOtherOptions % 2 != 0) {
        result++;
    }
    return result;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNISectionListOtherOptionsCell *otherOptionsCell = [tableView dequeueReusableCellWithIdentifier:MNISectionListOtherOptionsCellIdentifier forIndexPath:indexPath];
    // populate other option cell
    otherOptionsCell.delegate = self;
    NSInteger moreOptionsIdx = indexPath.row * 2;
    MNIConfigMoreOptionsModel *leftModel = self.obitsMoreOptions[moreOptionsIdx];
    otherOptionsCell.leftButton.tag = moreOptionsIdx;
    [otherOptionsCell.leftButton setTitle:leftModel.name forState:UIControlStateNormal];
    moreOptionsIdx++;
    if (moreOptionsIdx < self.obitsMoreOptions.count) {
        otherOptionsCell.rightButton.hidden = NO;
        MNIConfigMoreOptionsModel *rightModel = self.obitsMoreOptions[moreOptionsIdx];
        otherOptionsCell.rightButton.tag = moreOptionsIdx;
        [otherOptionsCell.rightButton setTitle:rightModel.name forState:UIControlStateNormal];
    } else {
        otherOptionsCell.rightButton.hidden = YES;
    }
    [otherOptionsCell setBackgroundColor:[UIColor clearColor]];
    BOOL isLightTheme = [[MNIThemeManager sharedThemeManager] isLightTheme];
    UIColor *titleColor = isLightTheme ? [UIColor colorWithRGBAString:@"000000ff"] : [UIColor colorWithRGBAString:@"ffffffff"];
    UIColor *backgroundColor = isLightTheme ? [UIColor colorWithRGBAString:@"DCDCDCff"] : [UIColor colorWithRGBAString:@"474747ff"];
    [otherOptionsCell.leftButton setBackgroundColor:backgroundColor];
    [otherOptionsCell.rightButton setBackgroundColor:backgroundColor];
    [otherOptionsCell.leftButton setTitleColor:titleColor forState:UIControlStateNormal];
    [otherOptionsCell.rightButton setTitleColor:titleColor forState:UIControlStateNormal];
    return otherOptionsCell;
}


#pragma mark - MNISectionListOtherOptionsCellDelegate

- (void)sectionListOtherOptionsCell:(MNISectionListOtherOptionsCell *)otherOptionsCell didSelectOtherOptionWithIndex:(NSInteger)otherOptionIndex {
    
    if (otherOptionIndex >= 0 && otherOptionIndex < self.obitsMoreOptions.count) {
        MNIConfigMoreOptionsModel *selectedItem = self.obitsMoreOptions[otherOptionIndex];
        MILogDebug(@"selected Other Options button with name \"%@\", type %ld, URL %@", selectedItem.name, (long)selectedItem.type, selectedItem.url);
        
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        MNIWebViewController *wvc = [(UINavigationController*)vc viewControllers][0];
        wvc.theUrl = [NSURL URLWithString:selectedItem.url];
        wvc.theTitle = selectedItem.name;
        [self.splitViewController presentViewController:vc animated:YES completion:nil];

    }
}


@end
