//
//  MNIWebViewController.m
//  phoenix-reader
//
//  Created by Yann Duran on 8/8/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNIWebViewController.h"
#import "MNIThemeManager.h"
#import "UIColor+ColorHelpers.h"

@implementation MNIWebViewController

- (void)setupUI
{
    self.navigationController.hidesBarsOnSwipe = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.navigationController.toolbar.hidden = YES;
    } else {
        //clean nav bar for phones
        self.navigationController.navigationBar.topItem.leftBarButtonItems = [NSArray arrayWithObject:self.navigationController.navigationBar.topItem.leftBarButtonItems[0]];
        self.navigationController.navigationBar.topItem.rightBarButtonItems = nil;
    }
    
    self.navigationController.toolbar.tintColor = [[MNIThemeManager sharedThemeManager] tintColor];
    self.navigationController.toolbar.barTintColor = [[MNIThemeManager sharedThemeManager] barTintColor];
    self.navigationController.navigationBar.tintColor = [[MNIThemeManager sharedThemeManager] tintColor];
    self.navigationController.navigationBar.barTintColor = [[MNIThemeManager sharedThemeManager] barTintColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [[MNIThemeManager sharedThemeManager] tintColor]}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    
    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    self.theWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:theConfiguration];
    self.theWebView.navigationDelegate = self;
    [self.theWebView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.theWebView];
    [self.theWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [self addContraintsToWebView];
    [self addProgressView];
    
    if (self.theUrl)
        [self.theWebView loadRequest:[NSURLRequest requestWithURL:self.theUrl]];
    
    if(self.theTitle)
        self.title = self.theTitle;
    
}
-(void)addContraintsToWebView{
    /*Top Contraint*/
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.theWebView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    
    /*Lead Contraint*/
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.theWebView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    
    /*Bottom Contraint*/
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.theWebView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    /*Trailing Contraint*/
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.theWebView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    
    [self.theWebView layoutIfNeeded];
    
}
- (void)addProgressView {
    self.theProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.theProgressView.tintColor = [UIColor getUIColorObjectFromHexString:MNIUIColor2020BrightBlue alpha:1.0];
    [self.navigationController.navigationBar addSubview:self.theProgressView];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    
    NSLayoutConstraint *constraint;
    constraint = [NSLayoutConstraint constraintWithItem:self.theProgressView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:navBar attribute:NSLayoutAttributeBottom multiplier:1 constant:-0.5];
    [self.navigationController.navigationBar addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.theProgressView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:navBar attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    [self.navigationController.navigationBar addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.theProgressView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:navBar attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self.navigationController.navigationBar addConstraint:constraint];
    
    [self.theProgressView setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == self.theWebView) {
        [self.theProgressView setAlpha:1.0f];
        [self.theProgressView setProgress:self.theWebView.estimatedProgress animated:YES];
        
        if(self.theWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.theProgressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.theProgressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.theWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.theWebView setNavigationDelegate:nil];
}
#pragma mark <WKNavigationDelegate>

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [self updateButtons];
}

#pragma mark -

- (void)updateButtons {
    if (self.theWebView.canGoBack) {
        self.backButton_nav.enabled = YES;
        self.backButton_tool.enabled = YES;
    } else {
        self.backButton_nav.enabled = NO;
        self.backButton_tool.enabled = NO;
    }
    
    if (self.theWebView.canGoForward) {
        self.fwdButton_nav.enabled = YES;
        self.fwdButton_tool.enabled = YES;
    } else {
        self.fwdButton_nav.enabled = NO;
        self.fwdButton_tool.enabled = NO;
    }
}

- (IBAction)moveBack:(id)sender{
    [self.theWebView goBack];
}

- (IBAction)moveforward:(id)sender{
    [self.theWebView goForward];
}

- (IBAction)refresh:(id)sender {
    [self.theWebView reload];
}

- (IBAction)moreActions:(id)sender {
    NSArray *itemsToShare = @[self.theTitle, self.theUrl];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityVC.popoverPresentationController.barButtonItem = sender;
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
