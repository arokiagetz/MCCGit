//
//  MNIPageViewController.m
//  phoenix-reader
//
//  Created by Sandeep on 7/12/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNIPageViewController.h"
#import "MNIPageViewModel.h"
#import "MNIStoryViewController.h"
#import "UIColor+ColorHelpers.h"
#import "MNIFbCommentsViewController.h"
#import "RootSplitViewController.h"

NSInteger const MNIMaxFBCommentCount = 9;

@interface MNIPageViewController () <MNIStoryViewControllerDelegate>

@property (nonatomic, strong) MNIPageViewModel *pageViewModel;

@end

@implementation MNIPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageViewModel = [[MNIPageViewModel alloc] initWithStoris:self.stories];
    [self setDelegate:self.pageViewModel];
    [self setDataSource:self.pageViewModel];
    
    CGFloat getBubbleIconWidth = [[MNIThemeManager sharedThemeManager] hollowCommandImage].size.width;
    CGFloat getBubbleIconHeight = [[MNIThemeManager sharedThemeManager] hollowCommandImage].size.height;
    self.fbCommentButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fbCommentButton setImage:[[MNIThemeManager sharedThemeManager] hollowCommandImage] forState:UIControlStateNormal];
    [self.fbCommentButton.titleLabel setText:@""];
    [self.fbCommentButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -getBubbleIconWidth, 0, 0)];
    [self.fbCommentButton.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:13]];
    [self.fbCommentButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.fbCommentButton setTitleColor:[[MNIThemeManager sharedThemeManager] barTintColor]forState:UIControlStateNormal];
    [self.fbCommentButton addTarget:self action:@selector(presentFbCommentsViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.fbCommentButton setFrame:CGRectMake(0, 0, getBubbleIconWidth, getBubbleIconHeight)];
    UIBarButtonItem *commentBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.fbCommentButton];
    NSMutableArray *tbItems = [self.navigationItem.rightBarButtonItems mutableCopy];
    //instead of remove and add the new button, use the replaceObjectAtIndex method.
    [tbItems replaceObjectAtIndex:1 withObject:commentBarButton];
    self.navigationItem.rightBarButtonItems = tbItems;
    
}

- (void)presentFbCommentsViewController{
    
    MasterViewModelItem *storyitem = self.stories[self.currentIndex];
    [self performSegueWithIdentifier:@"MNIShowFbCommentPage" sender:storyitem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController.navigationBar setTintColor:[UIColor barButtonTintColor]];
//    [self.navigationController.navigationBar setBarTintColor:[UIColor navBarTintColor]];

    [self setPagerVCs];
}

- (void)setPagerVCs
{
    MNIStoryViewController *storyViewController = [self.pageViewModel storyViewControllerAtIndex:self.currentIndex];
    storyViewController.delegate = self;
    if (storyViewController) {
        NSArray *viewControllers = @[storyViewController];
        [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
    [[self.navigationController navigationBar] setTintColor:[[MNIThemeManager sharedThemeManager] tintColor]];
    [[self.navigationController navigationBar] setBarTintColor:[[MNIThemeManager sharedThemeManager] barTintColor]];
    
//    /*Apply theme to barbuttons*/
//    self.share.tintColor = [UIColor barButtonTintColor];
//    self.bookMark.tintColor = [UIColor barButtonTintColor];
//    self.chat.tintColor = [UIColor barButtonTintColor];
}
- (IBAction)shareStory:(id)sender
{
    MasterViewModelItem *storyitem = self.stories[self.currentIndex];
    if (storyitem.storyModel.title != nil && storyitem.storyModel.url != nil) {
        NSArray *itemsToShare = @[storyitem.storyModel.title, storyitem.storyModel.url];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        activityVC.popoverPresentationController.barButtonItem = sender;
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange: previousTraitCollection];
    if (!self.fromPushMessage){
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
            self.navigationItem.leftBarButtonItem = nil;
        } else {
            [self showHideBarButtonItemDisplay];
        }
    }
}
-(void)showHideBarButtonItemDisplay{
    UIBarButtonItem *showHideBarButtomItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"StorylistHide"]
                                              style:self.splitViewController.displayModeButtonItem.style
                                              target:self.splitViewController.displayModeButtonItem.target
                                              action:self.splitViewController.displayModeButtonItem.action];
//    showHideBarButtomItem.tintColor = [UIColor barButtonTintColor];
    self.navigationItem.leftBarButtonItem = showHideBarButtomItem;
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // center cell
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // do nothing
        
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma Delegate methods - MNIStoryViewControllerDelegate

-(void)scrollToNextPage
{
    MNIStoryViewController *vc = (MNIStoryViewController*)self.viewControllers[0];
    self.currentIndex = (int)vc.pageIndex;
    self.currentIndex ++;
    [self setPagerVCs];
}

-(void)facebookCommentsCount:(NSInteger)commentsCount
{
    MNIThemeManager *themeManager = [MNIThemeManager sharedThemeManager];
    if (commentsCount == 0) {
        [self.fbCommentButton setImage:[themeManager hollowCommandImage] forState:UIControlStateNormal];
        [self.fbCommentButton setTitle:@"" forState:UIControlStateNormal];
    }
    else if (commentsCount) {
        [self.fbCommentButton setImage:[themeManager solidCommandImage] forState:UIControlStateNormal];
        NSString *getCounts = nil;
        if (commentsCount > MNIMaxFBCommentCount) {
            getCounts = [NSString stringWithFormat:@"%ld+",(long)MNIMaxFBCommentCount];
        }
        else {
            getCounts = [NSString stringWithFormat:@"%ld", (long)commentsCount];
        }
        [self.fbCommentButton setTitle:getCounts forState:UIControlStateNormal];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"MNIShowFbCommentPage"]) {
        MNIFbCommentsViewController *controller = (MNIFbCommentsViewController *)[[segue destinationViewController] topViewController];
        MasterViewModelItem *storyItem = sender;
        controller.storyUrl = storyItem.storyModel.url.absoluteString;
    }

}

@end
