//
//  MNISectionListViewController.m
//  phoenix-reader
//
//  Created by Scott Ferwerda on 5/9/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNISectionListViewController.h"
#import <BlocksKit/BlocksKit.h>
#import "MNIServerConfigManager.h"
#import "MNISectionPreferencesHandler.h"
#import "MNISectionListItemTableViewCell.h"
#import "MNISectionListOtherOptionsCell.h"
#import "UIColor+ColorHelpers.h"
#import "MNIUITheme.h"
#import "MILog.h"
#import "RootSplitViewController.h"


@interface MNISectionListViewModel : NSObject

@property (strong, nonatomic) NSMutableArray<MNIConfigSectionModel *> *sections;
@property (strong, nonatomic) NSArray<MNIConfigMoreOptionsModel *> *otherOptions;

@end

@implementation MNISectionListViewModel

@end

#pragma mark -

@interface MNISectionListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *otherOptionsHeaderView;

@property (strong, nonatomic) MNISectionListViewModel *viewModel;

@property (strong, nonatomic) NSDictionary *savedNavBarTextAttributes;

@property (assign, nonatomic) CGFloat otherOptionsCellHeight;
@property (assign, nonatomic) CGFloat otherOptionsHeaderViewHeight;

@end

@implementation MNISectionListViewController

static NSString * const MNISectionListItemCellIdentifier = @"MNISectionListItemTableViewCell";
static NSString * const MNISectionListOtherOptionsCellIdentifier = @"MNISectionListOtherOptionsCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // obtain heights for cells for each section, since they are different
    self.otherOptionsHeaderViewHeight = self.otherOptionsHeaderView.frame.size.height;
    MNISectionListOtherOptionsCell *otherOptionsCell = [self.tableView dequeueReusableCellWithIdentifier:MNISectionListOtherOptionsCellIdentifier];
    self.otherOptionsCellHeight = otherOptionsCell.frame.size.height;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupUI];

    self.navigationItem.title = NSLocalizedString(@"SECTIONS", nil);

    [self updateViewModelAndReload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self restoreUI];
//    MNIThemeManager *themeManager = [[MNIThemeManager alloc] init];
//    [themeManager applyTheme:YES];

    [super viewWillDisappear:animated];
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

#pragma mark -

- (void)setupUI
{
    // hack up the navbar
    self.savedNavBarTextAttributes = self.navigationController.navigationBar.titleTextAttributes;
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName: [UIFont fontWithName:@"McClatchySansCond-Demi" size:17.0f] };
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor getUIColorObjectFromHexString:@"0093d0" alpha:1.0];
    // when the section list is displayed, we want the master view to remain visible if we rotate
    if (self.splitViewController != nil) {
        RootSplitViewController *rootSVC = (RootSplitViewController *)(self.splitViewController);
        rootSVC.lockMasterView = YES;
    }
}

- (void)restoreUI
{
    self.navigationController.navigationBar.titleTextAttributes = self.savedNavBarTextAttributes;
    self.navigationController.navigationBar.barTintColor = [[MNIThemeManager sharedThemeManager] barTintColor];
    self.navigationController.navigationBar.tintColor = [[MNIThemeManager sharedThemeManager] tintColor];
    // unlock the master view since we're restoring state
    if (self.splitViewController != nil) {
        RootSplitViewController *rootSVC = (RootSplitViewController *)(self.splitViewController);
        rootSVC.lockMasterView = NO;
  }
}

- (void)updateViewModelAndReload
{
    [self updateViewModel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
        NSInteger i = NSNotFound;
        if (self.currentSelectedSectionID.length > 0) {
            i = [self.viewModel.sections indexOfObjectPassingTest:^BOOL(MNIConfigSectionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return [obj.section_id isEqualToString:self.currentSelectedSectionID];
            }];
        }
        if (i != NSNotFound) {
            NSIndexPath *idxpth = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView selectRowAtIndexPath:idxpth animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
    });
}

- (void)updateViewModel
{
    if (self.viewModel == nil) {
        self.viewModel = [[MNISectionListViewModel alloc] init];
    }
    if (self.viewModel.sections == nil) {
        // populate
        MNIServerConfigModel *serverConfigModel = [[MNIServerConfigManager sharedManager] serverConfigModel];
        NSArray<MNIConfigSectionModel *> *cfgUnfilteredSections = [[serverConfigModel sections_info] sections];
        NSString *topStorySectionID = serverConfigModel.sections_info.multisection.top_story_section_id;
        NSArray<MNIConfigSectionModel *> *cfgSections = [cfgUnfilteredSections bk_reject:^BOOL(MNIConfigSectionModel *obj) {
            return ([obj.section_id isEqualToString:@"multisection"] || [obj.section_id isEqualToString:topStorySectionID]);
        }];
        MNISectionPreferencesHandler *sectionPrefsHandler = [[MNISectionPreferencesHandler alloc] init];
        NSError *error = nil;
        NSArray<NSString *> *sectionOrder = [sectionPrefsHandler retrieveOrderedSectionIDsWithError:&error];
        if (error != nil || sectionOrder.count == 0) {
            sectionOrder = [cfgSections bk_map:^id(MNIConfigSectionModel *obj) {
                return obj.section_id;
            }];
        }
        NSMutableArray<MNIConfigSectionModel *> *orderedSectionModels = [[NSMutableArray alloc] initWithCapacity:cfgSections.count];
        NSMutableArray<MNIConfigSectionModel *> *unorderedSectionModels = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < cfgSections.count; i++) {
            MNIConfigSectionModel *aModel = cfgSections[i];
            if (aModel.type == MNISectionTypeSection) {
                if ([sectionOrder indexOfObject:aModel.section_id] != NSNotFound) {
                    // in the sorted list
                    [orderedSectionModels addObject:aModel];
                }
                else {
                    // unsorted
                    [unorderedSectionModels addObject:aModel];
                }
            }
            else {
                // not a regular section
                MILogError(@"unknown section type (%ld) found on section \"%@\".", (long)aModel.type, aModel.name);
            }
        }
        [orderedSectionModels sortUsingComparator:^NSComparisonResult(MNIConfigSectionModel * _Nonnull obj1, MNIConfigSectionModel * _Nonnull obj2) {
            NSComparisonResult result;
            NSUInteger sort1 = [sectionOrder indexOfObjectPassingTest:^BOOL(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return [obj isEqualToString:obj1.section_id];
            }];
            NSUInteger sort2 = [sectionOrder indexOfObjectPassingTest:^BOOL(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return [obj isEqualToString:obj2.section_id];
            }];
            if (sort1 < sort2) {
                result = NSOrderedAscending;
            }
            else if (sort1 > sort2) {
                result = NSOrderedDescending;
            }
            else {
                result = NSOrderedSame;
            }
            return result;
        }];
        
        self.viewModel.sections = [[NSMutableArray alloc] initWithCapacity:orderedSectionModels.count + unorderedSectionModels.count];
        [self.viewModel.sections addObjectsFromArray:orderedSectionModels];
        [self.viewModel.sections addObjectsFromArray:unorderedSectionModels];
        
        // handle "Other Options"
        self.viewModel.otherOptions = [serverConfigModel more_options];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger result = 1;
    if (self.viewModel.otherOptions.count > 0) result++;
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger result;
    if (section == 0) {
        result = self.viewModel.sections.count;
    }
    else {
        NSInteger numOtherOptions = self.viewModel.otherOptions.count;
        result = (numOtherOptions / 2);
        if (numOtherOptions % 2 != 0) result++;
    }
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *resultCell;
    if (indexPath.section == 0) {
        MNISectionListItemTableViewCell *itemCell = [tableView dequeueReusableCellWithIdentifier:MNISectionListItemCellIdentifier forIndexPath:indexPath];
        NSString *themeIdentifier = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? MNIUIThemeNameStandardLight : MNIUIThemeNameStandardDark);
        itemCell.themeIdentifier = themeIdentifier;
        MNIConfigSectionModel *aModel = self.viewModel.sections[indexPath.row];
        NSString *sectionName = aModel.name;
        itemCell.titleLabel.text = [sectionName uppercaseString];
        // remove footer hairline for last cell in section
        itemCell.cellSeparatorView.hidden = (indexPath.row == self.viewModel.sections.count - 1);
//        itemCell.selected = [self.currentSelectedSectionID isEqualToString:aModel.section_id];
//        if (itemCell.selected) {
//            NSLog(@"");
//        }
        resultCell = itemCell;
    }
    else {
        MNISectionListOtherOptionsCell *otherOptionsCell = [tableView dequeueReusableCellWithIdentifier:MNISectionListOtherOptionsCellIdentifier forIndexPath:indexPath];
        // populate other option cell
        otherOptionsCell.delegate = self;
        NSInteger moreOptionsIdx = indexPath.row * 2;
        MNIConfigMoreOptionsModel *leftModel = self.viewModel.otherOptions[moreOptionsIdx];
        otherOptionsCell.leftButton.tag = moreOptionsIdx;
        [otherOptionsCell.leftButton setTitle:leftModel.name forState:UIControlStateNormal];
        moreOptionsIdx++;
        if (moreOptionsIdx < self.viewModel.otherOptions.count) {
            otherOptionsCell.rightButton.hidden = NO;
            MNIConfigMoreOptionsModel *rightModel = self.viewModel.otherOptions[moreOptionsIdx];
            otherOptionsCell.rightButton.tag = moreOptionsIdx;
            [otherOptionsCell.rightButton setTitle:rightModel.name forState:UIControlStateNormal];
            // TODO: make selection highlighting work
        }
        else {
            // hide right button
            otherOptionsCell.rightButton.hidden = YES;
        }
        resultCell = otherOptionsCell;
    }
    return resultCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) return self.otherOptionsCellHeight;
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) return self.otherOptionsHeaderViewHeight;
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *result = nil;
    if (section == 1) {
        result = self.otherOptionsHeaderView;
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: remove highlight from old cell, highlight new cell
    if (indexPath.section == 0) {
        MNIConfigSectionModel *aModel = self.viewModel.sections[indexPath.row];
        
        [self restoreUI];
        
        if (self.sectionListViewDelegate != nil) {
            [self.sectionListViewDelegate mniSectionList:self didSelectSection:aModel];
        }
    }
    else {
        // do nothing - selects in section 1 should be handled by buttons
    }
}

#pragma mark - MNISectionListOtherOptionsCellDelegate

- (void)sectionListOtherOptionsCell:(MNISectionListOtherOptionsCell *)otherOptionsCell didSelectOtherOptionWithIndex:(NSInteger)otherOptionIndex
{
    MNIConfigMoreOptionsModel *moreOptionsModel = nil;
    if (otherOptionIndex >= 0 && otherOptionIndex < self.viewModel.otherOptions.count) {
        moreOptionsModel = self.viewModel.otherOptions[otherOptionIndex];
        
//        [self restoreUI];
        
        if (self.sectionListViewDelegate != nil) {
            [self.sectionListViewDelegate mniSectionList:self didSelectOtherOption:moreOptionsModel];
        }
    }
}

@end
