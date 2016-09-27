//
//  MNIWebViewController.h
//  phoenix-reader
//
//  Created by Yann Duran on 8/8/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface MNIWebViewController : UIViewController <WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *theWebView;
@property (strong, nonatomic) UIProgressView *theProgressView;
@property (strong, nonatomic) NSString *theTitle;
@property (strong, nonatomic) NSURL *theUrl;

- (IBAction)moveBack:(id)sender;
- (IBAction)moveforward:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)moreActions:(id)sender;

@property (weak, nonatomic)IBOutlet UIBarButtonItem *backButton_tool;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *fwdButton_tool;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *refreshButton_tool;

@property (weak, nonatomic)IBOutlet UIBarButtonItem *backButton_nav;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *fwdButton_nav;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *refreshButton_nav;

@end
