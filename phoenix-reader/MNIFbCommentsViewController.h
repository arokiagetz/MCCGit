//
//  MNIFbCommentsViewController.h
//  phoenix-reader
//
//  Created by Nishanth on 19/09/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface MNIFbCommentsViewController : UIViewController <WKNavigationDelegate,WKUIDelegate>

@property (strong, nonatomic) NSString *storyUrl;

@end
