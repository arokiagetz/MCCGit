//
//  MNISectionFrontViewController.m
//  phoenix-reader
//
//  Created by Scott Ferwerda on 5/20/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNISectionFrontViewController.h"
#import "RootSplitViewController.h"
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
#import "MNIMasterViewNavigationController.h"
#import "MNIThemeManager.h"
#import "MNIWebViewController.h"
#import "MNISectionCollectionViewCell.h"
#import "MNIGlobalConstants.h"


#import "MNISectionViewController.h"

NSInteger const MNITopTabPadding = 18;
NSInteger const MNITopTabHeight = 44;

#pragma mark -

@interface MNISectionFrontViewController () <UICollectionViewDataSource, UICollectionViewDelegate, MNISectionViewControllerDelegate,MNISectionTopTabViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (copy, nonatomic) NSArray <MNIConfigSectionModel *> *sectionsArray;


@end

@implementation MNISectionFrontViewController

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    // we want to know if the config changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleServerConfigUpdatedNotification:) name:MNIServerConfigDidUpdateNotification object:nil];
    
}

- (void)setUpSelectedThemeForceUpdate:(BOOL)isForceUpdate {
    MNIThemeManager *themeManager = [MNIThemeManager sharedThemeManager];
    
    [self.view setBackgroundColor:themeManager.backgroundColor];
    [self.collectionView setBackgroundColor:themeManager.barTintColor];
    if (isForceUpdate) {
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        [self.collectionView reloadData];
        [self setTabSelected:selectedIndexPath];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setUpSelectedThemeForceUpdate:NO];
    
}

- (void)setTabSelected:(NSIndexPath*)indexPath {
    
    [self.collectionView selectItemAtIndexPath:indexPath
                                      animated:YES
                                scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc {
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)setUpPageViewControllerWithServerConfig:(MNIServerConfigModel *)serverConfigModel {
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.sectionPageViewModel = [[MNISectionsPageViewModel alloc] initWithSections:[self getFormatedSections]];
    [self.pageViewController setDataSource:self.sectionPageViewModel];
    [self.pageViewController setDelegate:self.sectionPageViewModel];
    self.sectionPageViewModel.delegate = self;
    
    MNISuperSectionViewController *sectionTableViewController = [self.sectionPageViewModel sectionTableViewControllerAtIndex:0];
    [sectionTableViewController setDelegate:self];
    [self setViewControllersToPageViewController:@[sectionTableViewController] viewIndex:0];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    [self.pageViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary * views = @{@"pageView" : self.pageViewController.view, @"collectionView": self.collectionView};
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pageView]|"
                                                                   options:0
                                                                   metrics:0
                                                                     views:views];
    [self.view addConstraints:constraints];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[collectionView]-0-[pageView]|"
                                                          options:0
                                                          metrics:0
                                                            views:views];
    [self.view addConstraints:constraints];
    
    [self.pageViewController didMoveToParentViewController:self];
    [self.collectionView reloadData];
}


- (NSArray<MNIConfigSectionModel *> *)getFormatedSections {
    
    MNIServerConfigModel *serverConfigModel = [[MNIServerConfigManager sharedManager] serverConfigModel];
    
    NSMutableArray<MNIConfigSectionModel *> *sections = [[NSMutableArray alloc] initWithArray:serverConfigModel.sections_info.sections];
    [sections addObject:[self createDummyMNIConfigSectionModelWithName:MNIObitsMoreSectionName withSectionID:@""]];
    return sections;
}


#pragma mark - CollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.sectionsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MNISectionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SectionCellIdentifier" forIndexPath:indexPath];
    MNIConfigSectionModel *sectionModel = self.sectionsArray [indexPath.item];
    [cell setSectionName:sectionModel.name];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    MNIConfigSectionModel *sectionModel = self.sectionsArray [indexPath.item];
    NSString *someString = [sectionModel.name uppercaseString];
    UIFont *labelFont = [UIFont fontWithName:MNIMcClatchySansRegularFontName size:12];
    CGSize stringBoundingBox = [someString sizeWithAttributes:@{NSFontAttributeName:labelFont}];
    CGSize cellSize = CGSizeMake(MNITopTabPadding + stringBoundingBox.width + MNITopTabPadding, MNITopTabHeight);
    return cellSize;
}


#pragma mark - CollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    MNIConfigSectionModel *sectionModel = self.sectionsArray [indexPath.item];
    [self swipeToSectionWithSectionId:sectionModel.section_id sectionName:sectionModel.name];
    
}

#pragma mark - getters/setters

- (NSArray <MNIConfigSectionModel *> *)sectionsArray {
    MNIServerConfigModel *serverConfigModel = [[MNIServerConfigManager sharedManager] serverConfigModel];
    if (!_sectionsArray && serverConfigModel) {
        _sectionsArray = [[NSArray alloc] initWithArray:[self getFormatedSections] copyItems:YES];
        _sectionsArray[0].name = MNIHomeSectionName;
    }
    return  _sectionsArray;
}


- (MNIConfigSectionModel *)createDummyMNIConfigSectionModelWithName:(NSString *)sectionName withSectionID:(NSString *)sectionId {
    MNIConfigSectionModel *sectionModel = [[MNIConfigSectionModel alloc] init];
    sectionModel.name = sectionName;
    sectionModel.section_id = sectionId;
    return sectionModel;
}


#pragma mark - notification handlers

- (void)handleServerConfigUpdatedNotification:(NSNotification *)notification
{
    MNIServerConfigManager *configManager = notification.object;
    if (configManager == [MNIServerConfigManager sharedManager]) {
        MNIServerConfigModel *serverConfigModel = [configManager serverConfigModel];
        [self setUpPageViewControllerWithServerConfig:serverConfigModel];
        [self setTabSelected:[NSIndexPath indexPathForItem:0 inSection:0]];
    }
}



#pragma mark - IBActions

- (IBAction)settingsButtonTouched:(id)sender {
    [[MNIThemeManager sharedThemeManager] applyTheme];
}


- (IBAction)dismissModalVC:(UIStoryboardSegue *)segue
{
    //do nothing
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)setupUI {
    // Removing nav bar shadow
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationItem setHidesBackButton:YES];
}

-(void)swipeToSectionWithSectionId:(NSString*)sectionId sectionName:(NSString*)sectionName{
   // Swipe left and right the sections depends on SectionHeader Selection
    MNIConfigSectionModel *configSectionModel = [[self getFormatedSections] bk_match:^BOOL(MNIConfigSectionModel *aConfigSectionModel) {
        if ([sectionName isEqualToString:MNIHomeSectionName]) {
            return [sectionId isEqualToString:aConfigSectionModel.section_id];
        } else{
           return [sectionName isEqualToString:aConfigSectionModel.name];
        }
    }];
    NSInteger index = [[self getFormatedSections] indexOfObject:configSectionModel];
    MNISuperSectionViewController *sectionVC = [self.sectionPageViewModel sectionTableViewControllerAtIndex:index];
    [sectionVC setDelegate:self];
    [self setViewControllersToPageViewController:@[sectionVC] viewIndex:index];
    self.selectedSectionIndex = index;
}
#pragma mark - MNISectionViewControllerDelegate

-(void)sectionTableViewController:(MNISectionViewController *)sectionTableViewController moveToSectionWithSectionId:(NSString *)sectionId {
    MNIConfigSectionModel *configSectionModel = [[self getFormatedSections] bk_match:^BOOL(MNIConfigSectionModel *aConfigSectionModel) {
        return [sectionId isEqualToString:aConfigSectionModel.section_id];
    }];
    NSInteger index = [[self getFormatedSections] indexOfObject:configSectionModel];
    MNISuperSectionViewController *sectionVC = [self.sectionPageViewModel sectionTableViewControllerAtIndex:index];
    [sectionVC setDelegate:self];
    [self setViewControllersToPageViewController:@[sectionVC] viewIndex:index];
    [self.sectionPageViewModel.delegate sectionHeaderSelection:index];
}
#pragma mark - MNISectionHeaderViewDelegate

-(void)sectionHeaderSelection:(NSUInteger)pageIndex{
    // Change SectionHeader Selection depends on sections swiped
    [self.collectionView reloadData];
    [self setTabSelected:[NSIndexPath indexPathForItem:pageIndex inSection:0]];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:pageIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    self.selectedSectionIndex = pageIndex;
}
-(void)setViewControllersToPageViewController:(NSArray*)viewControllers viewIndex:(NSUInteger)index{
    if (index<self.selectedSectionIndex) {
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    } else{
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}
@end
