//
//  MNISectionViewController.m
//  phoenix-reader
//
//  Created by Sandeep on 9/2/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNISectionViewController.h"
#import "MasterViewModels.h"

#import <BlocksKit/BlocksKit.h>
#import "MILog.h"
#import "MNIServerConfigManager.h"
#import "MNISectionPreferencesHandler.h"
#import "MNISectionFrontStoryCell.h"
#import "NSDate+helper.h"
#import "MNIUITheme.h"
#import "MNIHeaderView.h"
#import "MNISectionSubmenuTableViewController.h"
#import "MNIPageViewController.h"
#import "UIColor+ColorHelpers.h"
#import "NSString+helper.h"

#import "SectionPreferences.h"
#import "MNISectionListViewController.h"
#import "MNISectionFrontMoreStoriesCell.h"
#import "MNIHeaderView.h"
#import "MNISectionSubmenuTableViewController.h"
#import "MNISectionFrontViewController.h"
#import "RootSplitViewController.h"
#import "MNISectionManager.h"

NSString * const MNISectionFrontBasicStoryCellIdentifier = @"SectionFrontBasicStoryCell";
NSString * const MNISectionFrontGalleryStoryCellIdentifier = @"SectionFrontGalleryStoryCell";
NSString * const MNISectionFrontTopStoryCellIdentifier = @"SectionFrontTopStoryCell";
NSString * const MNISectionFrontMoreStoriesCellIdentifier = @"SectionFrontMoreStoriesCell";

NSString * const MNISectionFrontHeaderViewIdentifier = @"SectionFrontHeaderViewIdentifier";



@interface MNISectionViewController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, MNISectionFrontMoreStoriesCellDelegate, MNIHeaderViewDelegate, MNISectionSubmenuDelegate>

@property (strong, nonatomic) MasterViewModel *masterViewModel;
@property (strong, nonatomic) NSArray<MNIConfigSectionModel *> *sections; // ID's of sections to display - more than one section supplied here indicates this is the Home/MSSF section
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (assign, nonatomic) BOOL isRequestProcess;
@property (strong, nonatomic) MNISectionManager *sectionManager;


@end

@implementation MNISectionViewController

#pragma mark - App Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.sectionModel isTopSection]) {
        self.sections = [self getHomeSectionConfigModels];
    } else {
        self.sections = @[self.sectionModel];
    }
    
    self.masterViewModel = [[MasterViewModel alloc] initWithSectionIDs:self.sections];
    [self setupUI];
    self.isRequestProcess = YES;
    [self getSectionContentWithActivityIndicator:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.isRequestProcess) {
        [self getSectionContentWithActivityIndicator:YES];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self dismissCurrentlyPresentedSectionSubmenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI {

    // Add refresh control to table view
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlEvent:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    // register nibs
    UINib *cellNib;
    cellNib = [UINib nibWithNibName:@"MNISectionFrontBasicStoryCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:MNISectionFrontBasicStoryCellIdentifier];
    cellNib = [UINib nibWithNibName:@"MNISectionFrontGalleryStoryCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:MNISectionFrontGalleryStoryCellIdentifier];
    cellNib = [UINib nibWithNibName:@"MNISectionFrontTopStoryCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:MNISectionFrontTopStoryCellIdentifier];
    cellNib = [UINib nibWithNibName:@"MNISectionFrontMoreStoriesCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:MNISectionFrontMoreStoriesCellIdentifier];
    
    cellNib = [UINib nibWithNibName:@"MNIHeaderView" bundle:nil];
    [self.tableView registerNib:cellNib forHeaderFooterViewReuseIdentifier:MNISectionFrontHeaderViewIdentifier];
    
    // set up table view for auto sizing
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 120.0;
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    
}


#pragma mark - Custom Setter/Getter
-(MNISectionManager *)sectionManager {
    if (!_sectionManager) {
        _sectionManager = [[MNISectionManager alloc] init];
    }
    return _sectionManager;
}


#pragma mark - Selector Methods

- (void)refreshControlEvent:(UIRefreshControl *)refreshControl {
//    [self updateFetchedResultsControllerWithServerCall:YES];
    [self getSectionContentWithActivityIndicator:YES];
}


#pragma mark - UITalbeViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MasterViewModelSection *modelSection = self.masterViewModel.sections[indexPath.section];
    if (indexPath.row < [modelSection.sectionItems count]) {
        MasterViewModelItem *masterViewModelItem = modelSection.sectionItems[indexPath.row];
        [self performSegueWithIdentifier:@"MNIShowStoryDetail" sender:masterViewModelItem];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger result = self.masterViewModel.sections.count;
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger numStoriesAvailable = self.masterViewModel.sections[section].sectionItems.count;
    MNIConfigSectionModel *sectionModel = self.masterViewModel.sections[section].sectionConfig;
    // For Showing More Stories Only for MSSF(exclusive of Top Story) and not for section Page
    if (![sectionModel isTopSection] && [self.masterViewModel isMultisectionViewModel]) {
        numStoriesAvailable++;
    }
    return numStoriesAvailable;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static CGFloat moreStoriesCellHeight = 0.0;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MNISectionFrontStoryCell *moreStoriesSizingCell = [tableView dequeueReusableCellWithIdentifier:MNISectionFrontMoreStoriesCellIdentifier];
        moreStoriesCellHeight = moreStoriesSizingCell.frame.size.height;
    });
    
    CGFloat cellHeight;
    NSArray<MasterViewModelItem *> *sectionItems = self.masterViewModel.sections[indexPath.section].sectionItems;
    NSUInteger numStoriesInSection = sectionItems.count;
    if (indexPath.row < numStoriesInSection) {
        cellHeight = UITableViewAutomaticDimension;
    } else {
        // more stories cell
        cellHeight = moreStoriesCellHeight;
    }
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    // TODO: implement other cell types when they are available
    MasterViewModelSection *aVMSection = self.masterViewModel.sections[indexPath.section];
    NSArray<MasterViewModelItem *> *sectionItems = aVMSection.sectionItems;
    NSUInteger numStoriesInSection = sectionItems.count;
    if (indexPath.row < numStoriesInSection) {
        MasterViewModelItem *aVMItem = sectionItems[indexPath.row];
        NSString *cellIdentifier;
        NSAssert(aVMItem.itemType == MasterViewModelItemTypeNormal, @"support for ads not implemented yet");
        if (aVMItem.itemType == MasterViewModelItemTypeNormal) {
            if (aVMItem.normalItemSubtype == MasterViewModelNormalItemTypeTopStory) {
                cellIdentifier = MNISectionFrontTopStoryCellIdentifier;
            } else if (aVMItem.normalItemSubtype == MasterViewModelNormalItemTypePhotoGalleryStory ||
                       aVMItem.normalItemSubtype == MasterViewModelNormalItemTypeVideoGalleryStory ||
                       aVMItem.normalItemSubtype == MasterViewModelNormalItemTypeSectionLeadStory) {
                cellIdentifier = MNISectionFrontGalleryStoryCellIdentifier;
            } else { // MasterViewModelNormalItemTypeStory
                cellIdentifier = MNISectionFrontBasicStoryCellIdentifier;
            }
        } else {
            // TODO: implement support for ads
        }
        MNISectionFrontStoryCell *storyCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [self configureCell:storyCell withViewModelItem:aVMItem];
        
        cell = storyCell;
    }
    else {
        // more stories
        MNISectionFrontMoreStoriesCell *moreCell = [tableView dequeueReusableCellWithIdentifier:MNISectionFrontMoreStoriesCellIdentifier forIndexPath:indexPath];
        moreCell.tag = indexPath.section;
        moreCell.delegate = self;
        NSString *titleFormat = NSLocalizedString(@"MORE %@ STORIES", nil);
        MasterViewModelSection *aVMSection = self.masterViewModel.sections[indexPath.section];
        NSString *title = [NSString stringWithFormat:titleFormat, [aVMSection.sectionName uppercaseString]];
        [moreCell.moreStoriesButton setTitle:title forState:UIControlStateNormal];
        cell = moreCell;
    }
    return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MNIHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:MNISectionFrontHeaderViewIdentifier];
    headerView.tag = section;
    headerView.delegate = self;
    MasterViewModelSection *aVMSec = self.masterViewModel.sections[section];
    NSArray<MasterViewModelItem *> *sectionItems = aVMSec.sectionItems;
    
    MasterViewModelItem *aVMItem = [sectionItems firstObject];
    if (aVMItem.itemType == MasterViewModelItemTypeNormal) {
        if (aVMItem.normalItemSubtype == MasterViewModelNormalItemTypeTopStory) {
            [headerView.headerButton setTitleColor:[UIColor colorWithRed:0.0/255.0 green:147.0/255.0 blue:208/255.0 alpha:1.0] forState:UIControlStateNormal];
            headerView.headerButton.backgroundColor = [UIColor headerViewBGColor:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone];
        }
    }
    [headerView.headerButton setUserInteractionEnabled:!aVMSec.isTopStoriesSection];
    [headerView setHeaderButtonTitle:aVMSec.sectionName]; // to be set to the section name/title
    [headerView setDropDownButtonHidden:[self.masterViewModel isMultisectionViewModel]]; // to be set to NO when section has sub-sections
    [headerView.contentView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (void)configureCell:(UITableViewCell<MNISectionFrontStoryCellProtocol> *)cell withViewModelItem:(MasterViewModelItem *)vmItem {

    NSAssert(vmItem.storyModel != nil, @"story content unexpectedly nil");
    [cell configureCellWithVMItem:vmItem];
}


- (void)getSectionContentWithActivityIndicator:(BOOL)isActivityIndicator {
   
    __weak MNISectionViewController *weakSelf = self;
    [self.sectionManager getUpdatedSectionsforSectionID:self.sections withComplitionHandeler:^(NSArray *fetchedSections, NSError *error, BOOL isDownloading) {
        if (isActivityIndicator && isDownloading) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.refreshControl beginRefreshing];
            });
            weakSelf.isRequestProcess = YES;
        }
        [self.masterViewModel rebuildViewModelWithSectionFetchedResult:fetchedSections];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            if ([weakSelf.refreshControl isRefreshing] && !isDownloading) {
                [weakSelf.refreshControl endRefreshing];
            }
        });
    }];
}


- (IBAction)dismissModalVC:(UIStoryboardSegue *)segue {
    //do nothing
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (IBAction)didPressSectionListButton:(id)sender
{
    // for visual feedback only
    NSLog(@"section list pressed!");
}

#pragma mark - MNISectionFrontMoreStoriesCellDelegate

- (void)buttonPressedInMoreStoriesCell:(MNISectionFrontMoreStoriesCell *)cell {
    NSInteger section = cell.tag;
    NSString *newSectionID = self.masterViewModel.sections[section].sectionID;
    [self moveToSectionWithSectionId:newSectionID];
}



#pragma mark - MNIHeaderViewDelegate

- (void)mniHeaderView:(MNIHeaderView *)headerView didToggleDropDownButtonToOpened:(BOOL)opened {
    NSInteger section = headerView.tag;
    MasterViewModelSection *aVMSection = self.masterViewModel.sections[section];
    //    UIImage *img = [self pb_takeSnapshot:self.tableView];
    if (opened) {
        // load from sb
        UIStoryboard *submenuStoryboard = [UIStoryboard storyboardWithName:@"MNISectionSubmenu" bundle:nil];
        MNISectionSubmenuTableViewController *submenuVC = [submenuStoryboard instantiateViewControllerWithIdentifier:@"MNISectionSubmenuTableViewController"];
        NSMutableArray *subSections = [NSMutableArray arrayWithArray:aVMSection.subsections];
        [subSections insertObject:aVMSection.sectionConfig atIndex:0];
        submenuVC.subsections = subSections;
        submenuVC.selectedSectionID = aVMSection.sectionID;
        submenuVC.submenuDelegate = self;
        
        CGFloat x = CGRectGetMinX(headerView.bounds);
        CGFloat y = CGRectGetMaxY(headerView.bounds);
        CGPoint headerBottomLeft = CGPointMake(x, y);
        [headerView setUserInteractionEnabled:NO];
        [self presentSectionSubmenu:submenuVC fromTopLeftPoint:headerBottomLeft withHeaderView:headerView];
    } else {
        [self dismissCurrentlyPresentedSectionSubmenu];
    }
}

- (void)sectionHeaderTouchedForMNIHeaderView:(MNIHeaderView *)headerView {
    NSInteger section = headerView.tag;
    MasterViewModelSection *aVMSection = self.masterViewModel.sections[section];
    NSString *sectionIDToShow = aVMSection.sectionID;
    // if MSSF, or somehow not right section, show selected section
    if (self.sections.count > 1 || ![aVMSection.sectionConfig isTopSection]) {
        // ... unless it's the top story, we don't have a section for that
        [self moveToSectionWithSectionId:sectionIDToShow];
    }
}

- (void)moveToSectionWithSectionId:(NSString *)sectionId {
    if (self.delegate) {
        [self.delegate sectionTableViewController:self moveToSectionWithSectionId:sectionId];
    }
}


#pragma mark - subsection dropdown management

- (void)presentSectionSubmenu:(MNISectionSubmenuTableViewController *)submenuVC fromTopLeftPoint:(CGPoint)topLeftPoint withHeaderView:(MNIHeaderView *)headerView {
    CGFloat w = self.tableView.frame.size.width - topLeftPoint.x;
    CGFloat h = self.tableView.frame.size.height - topLeftPoint.y;
    CGRect newSubmenuFrame = CGRectMake(topLeftPoint.x, topLeftPoint.y, w, h);
    [self addChildViewController:submenuVC];
    [self.view addSubview:submenuVC.view];
    submenuVC.view.frame = CGRectMake(newSubmenuFrame.origin.x, newSubmenuFrame.origin.y, newSubmenuFrame.size.width, 1);
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        submenuVC.tableView.frame = newSubmenuFrame;
    } completion:^(BOOL finished) {
        [submenuVC didMoveToParentViewController:self];
        [headerView setUserInteractionEnabled:YES];
    }];
}

- (void)dismissSectionSubmenu:(MNISectionSubmenuTableViewController *)submenuVC {
    [submenuVC willMoveToParentViewController:nil];
    CGRect newSubmenuFrame = CGRectMake(submenuVC.tableView.frame.origin.x, submenuVC.tableView.frame.origin.y, submenuVC.tableView.frame.size.width, 1);
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        submenuVC.tableView.frame = newSubmenuFrame;
    } completion:^(BOOL finished) {
        [submenuVC.tableView removeFromSuperview];
        [submenuVC removeFromParentViewController];
    }];
}

- (void)dismissCurrentlyPresentedSectionSubmenu {
    NSInteger childVCIndex = [self.childViewControllers indexOfObjectPassingTest:^BOOL(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return ([obj isKindOfClass:[MNISectionSubmenuTableViewController class]]);
    }];
    if (childVCIndex != NSNotFound) {
        MNISectionSubmenuTableViewController *submenuVC = self.childViewControllers[childVCIndex];
        [self dismissSectionSubmenu:submenuVC];
        MNIHeaderView *headerView = (MNIHeaderView *)[self.tableView headerViewForSection:0];
        [headerView.dropDownButton setSelected:NO];
    }
}

#pragma mark - MNISectionSubmenuDelegate

- (void)sectionSubmenu:(MNISectionSubmenuTableViewController *)sectionSubmenu didSelectSubsection:(MNIConfigSectionModel *)subSection {
    [self dismissCurrentlyPresentedSectionSubmenu];
    self.sections = @[subSection];
    self.masterViewModel.orderedSections = @[subSection];
    [self getSectionContentWithActivityIndicator:YES];
}



#pragma mark - Navigation

- (NSArray *)getCleanStoryList {
    NSMutableArray *arrayOfStories = [NSMutableArray new];
    for (MasterViewModelSection *modelSection in self.masterViewModel.sections) {
        for (MasterViewModelItem *modelItem in modelSection.sectionItems) {
            [arrayOfStories addObject:modelItem];
        }
    }
    return arrayOfStories;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"MNIShowStoryDetail"]) {
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSArray *cleanStoryList = [self getCleanStoryList];
        
        MNIPageViewController *controller = (MNIPageViewController *)[[segue destinationViewController] topViewController];
        [controller setStories:cleanStoryList];
        [controller setCurrentIndex:(int)[cleanStoryList indexOfObject:sender]];
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        // Hide master
        [(RootSplitViewController*)self.splitViewController toggleMasterView];
    }
}


- (NSArray <MNIConfigSectionModel *> *)getHomeSectionConfigModels {
    
    MNIConfigSectionsInfoModel *sectionInfo = [[[MNIServerConfigManager sharedManager] serverConfigModel] sections_info];
    // Adding 1 to get total multisecion including Top Story
    NSInteger sectionsInHome = sectionInfo.multisection.sections_shown + 1;
    return [sectionInfo.sections subarrayWithRange:NSMakeRange(0, sectionsInHome)];
}


@end
