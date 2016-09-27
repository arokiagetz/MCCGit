//
//  MNIFbCommentsViewController.m
//  phoenix-reader
//
//  Created by Nishanth on 19/09/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNIFbCommentsViewController.h"
#import "MNIServerConfigManager.h"
#import "MNIThemeManager.h"
#import "UIColor+ColorHelpers.h"

@interface MNIFbCommentsViewController ()

@property (strong, nonatomic) WKWebView *fbWebView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation MNIFbCommentsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self loadWeb];
}

- (void)setupUI
{
    self.title = NSLocalizedString(@"Comments", @"Comments");
    self.navigationController.navigationBar.tintColor = [[MNIThemeManager sharedThemeManager] tintColor];
    self.navigationController.navigationBar.barTintColor = [[MNIThemeManager sharedThemeManager] barTintColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [[MNIThemeManager sharedThemeManager] tintColor]}];
    
    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    theConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    theConfiguration.preferences.javaScriptEnabled = YES;
    self.fbWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:theConfiguration];
    self.fbWebView.navigationDelegate = self;
    self.fbWebView.UIDelegate = self;
    [self.fbWebView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.fbWebView];
    [self addContraintsToWebView];

    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    self.activityIndicator.center = self.view.center;
    [self.view addSubview: self.activityIndicator];
    [self.view bringSubviewToFront:self.activityIndicator];
}

- (void)addContraintsToWebView{
    /*Top Contraint*/
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.fbWebView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    
    /*Lead Contraint*/
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.fbWebView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    
    /*Bottom Contraint*/
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.fbWebView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    /*Trailing Contraint*/
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.fbWebView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    
    [self.fbWebView layoutIfNeeded];
    
}

- (void)loadWeb
{
    [self.fbWebView stopLoading];
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"FbCommentsPage" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%url%" withString:self.storyUrl];
    
    NSString *fbKey = [[[[[MNIServerConfigManager sharedManager] serverConfigModel] social] facebook] api_key];
    if (fbKey) {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%FBCommentsApiKey%" withString:fbKey];
    }
    BOOL isLightTheme = [[MNIThemeManager sharedThemeManager] isLightTheme];    //standard-light
    if (isLightTheme) {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%theme%" withString:@"light"];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%bgcolor%" withString:@"white"];
    }
    else {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%theme%" withString:@"dark"];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%bgcolor%" withString:@"black"];
    }
    
    NSString *locale = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDevelopmentRegion"];
    if ([locale isEqualToString:@"es"]) {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"en_US" withString:@"es_LA"];
    }
    
    [self.fbWebView loadHTMLString:htmlString baseURL:[NSURL URLWithString:self.storyUrl]];
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.fbWebView isLoading]) {
        [self.fbWebView stopLoading];
    }
    self.fbWebView = nil;    // disconnect the delegate as the webview is hidden
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (IBAction)closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark <WKNavigationDelegate>


- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    
    if (!navigationAction.targetFrame.isMainFrame) {
        
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.activityIndicator startAnimating];
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.activityIndicator stopAnimating];
    
    NSString *url = webView.URL.absoluteString;
    
    if([url containsString:@"https://m.facebook.com/plugins/close_popup.php?"]) {
        [self loadWeb];
    }
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    decisionHandler(WKNavigationActionPolicyAllow);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self.fbWebView setNavigationDelegate:nil];
    [self.fbWebView setUIDelegate:nil];
    self.fbWebView = nil;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
