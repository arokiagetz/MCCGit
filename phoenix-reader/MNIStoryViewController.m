//
//  MNIStoryViewController.m
//  phoenix-reader
//
//  Created by Sandeep on 7/12/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNIStoryViewController.h"
#import "DetailViewModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "UIImage+helper.h"
#import "MNIGradientView.h"

#define MNIStandardStoryImageAspectRatio 2/3
#define iPadProLanscape ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && [UIScreen mainScreen].bounds.size.width == 1366)
#define iPadProPortrait ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && [UIScreen mainScreen].bounds.size.height == 1366)
#define alphaValue 1.85
#define leadImageScrollOffset 10
#define iPadProTopLinesBottomConstraint 80
#define iPadTopLinesBottomConstraint 50
NSInteger const MNIMaxFBCommentsCount = 9;

@interface MNIStoryViewController ()<UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *storyWebView;
@property (weak, nonatomic) IBOutlet UIImageView *storyImageView;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UILabel *headLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *leadTextLabel;
@property (weak, nonatomic) IBOutlet UIView *topStoryView;
@property (weak, nonatomic) IBOutlet UIView *topicView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aspectRatioConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadTextBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storyImageviewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *galleryIconbottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iPhoneheadLineBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *galleryview;
@property (weak, nonatomic) IBOutlet UIImageView *videoiconImg;
@property (weak, nonatomic) IBOutlet UILabel *galleryCountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblTrailingconstraint;
@property (assign,nonatomic)BOOL isToggleVideo;

@property (nonatomic, strong) DetailViewModel *detailViewModel;
@property (nonatomic, strong) MNIGradientView *gradientView;
@property (nonatomic, strong) NSMutableDictionary *previousOffsetDictonary;
@property (nonatomic, strong) MNIURLDownloader *downloader;
@end

@implementation MNIStoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.previousOffsetDictonary = [NSMutableDictionary dictionary];
    self.storyWebView.scrollView.delegate = self;
    NSString *htmlString = [self.detailViewModel buildStoryContentStringFromStoryModel:self.storyModelItem withTraitCollection:self.traitCollection andNextStory:self.nextStoryModelItem];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [self.storyWebView loadHTMLString:htmlString baseURL:baseURL];
    [self.storyImageView setClipsToBounds:YES];
    [self.storyImageView setHidden:!self.storyModelItem.storyModel.thumbnail];
   // NSString *placeholderImageName = self.storyModelItem.normalItemSubtype == MasterViewModelNormalItemTypeTopStory ? @"Placeholder1x1" : @"Placeholder3x2";
    NSString *placeholderImageName = @"FailurePlaceholder";
    // [self.storyImageView sd_setImageWithURL:[NSURL URLWithString:self.storyModelItem.storyModel.thumbnail] placeholderImage:[UIImage imageNamed:placeholderImageName]];
    /*Replaced the method with ActivityIndicator*/
    [self.storyImageView setImageWithURL:[NSURL URLWithString:self.storyModelItem.storyModel.thumbnail] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
        if (error) {
            self.storyImageView.image = [UIImage imageNamed:placeholderImageName];
        }
    }usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    //Top Story
    if (self.storyModelItem.normalItemSubtype == MasterViewModelNormalItemTypeTopStory) {
        
        //set Topic font and text
        self.topicLabel.font = [self.detailViewModel setTopicTextFont];
        self.topicLabel.text = [self.detailViewModel setTopicText:self.storyModelItem.storyModel.topic];
        if ([self.topicLabel.text isEqualToString:@""]||self.topicLabel.text == nil) {
            self.topicView.backgroundColor = [UIColor clearColor];
        }
        
        self.topicView.hidden = self.storyModelItem.storyModel.topic ? NO : YES;
        
        //set headline font and text
        self.headLineLabel.font = [self.detailViewModel setHeadLineTextFont];
        self.headLineLabel.attributedText = [self.detailViewModel setHeadLineText:self.storyModelItem.storyModel.title];
        //set Toplines font and text
        self.leadTextLabel.font = [self.detailViewModel setTopLineTextFont];
        self.leadTextLabel.attributedText = [self.detailViewModel setTopLineText:self.storyModelItem.storyModel.leadtext];
        
        //Add gradienst laye to imageview
        self.gradientView = [[MNIGradientView alloc] initWithFrame:self.storyImageView.bounds];
        self.gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.detailViewModel addGradientsToImageView:self.gradientView.layer];
        [self.storyImageView addSubview:self.gradientView];
        self.gradientView.hidden = NO;
        // [self.detailViewModel addGradientsToImageView:self.storyImageView.gradientLayer];
        // self.storyImageView.gradientLayer.hidden = NO;
        self.aspectRatioConstraint.constant = 0;
        
    } else {
        //standard story
        [self.topicLabel setHidden:YES];
        [self.headLineLabel setHidden:YES];
        [self.leadTextLabel setHidden:YES];
        self.topicView.backgroundColor = [UIColor clearColor];
        self.gradientView.hidden = YES;
        // self.storyImageView.gradientLayer.hidden = YES;
        CGFloat factor = self.view.frame.size.height > self.view.frame.size.width ? self.view.frame.size.width : self.view.frame.size.height;
        self.aspectRatioConstraint.constant = factor - (factor*MNIStandardStoryImageAspectRatio);
    }
    
    
    //Get the Lead Asset
    MNIStoryModel *leadAssetModel = [self.detailViewModel leadAssetmodel:self.storyModelItem.storyModel.assets];
    if (leadAssetModel!=nil) {
        if (leadAssetModel.normalItemSubtype == StoryAssetsModelNormalItemTypePhotoGalleryStory) {
            // handle gallery icon depends on the lead Asset
            [self loadPhotoGalleryIcon:leadAssetModel];
        }
        else if(leadAssetModel.normalItemSubtype == StoryAssetsModelNormalItemTypeVideoGalleryStory){
            // handle video icon depends on the lead Asset
            [self displayVideoIcon];
        }
    }
    else{
        if (self.storyModelItem.normalItemSubtype == MasterViewModelNormalItemTypePhotoGalleryStory) {
            // handle gallery icon when lead asset nil
            [self loadPhotoGalleryIcon:self.storyModelItem.storyModel];
            
        }
        else if(self.storyModelItem.normalItemSubtype == MasterViewModelNormalItemTypeVideoGalleryStory) {
            // handle video icon when lead asset nil
            [self displayVideoIcon];
        }
        else if(self.storyModelItem.normalItemSubtype == MasterViewModelNormalItemTypeSectionLeadStory) {
            /*Handle Leadsection story asset type*/
            [self.detailViewModel leadSectionStoryAssestType:self.storyModelItem.storyModel];
            if (self.storyModelItem.storyModel.normalItemSubtype == StoryAssetsModelNormalItemTypeVideoGalleryStory) {
                //handle video
                [self displayVideoIcon];
            }
            else if (self.storyModelItem.storyModel.normalItemSubtype == StoryAssetsModelNormalItemTypePhotoGalleryStory) {
                //handle gallery
                [self loadPhotoGalleryIcon:self.storyModelItem.storyModel];
            }
        }
        else{
            //Lead Asset is nil
            //Other than Photo Gallery Story and Video Gallery story
            self.galleryview.hidden = YES;
            self.videoiconImg.hidden = YES;
        }
    }
    
    //Add Tapgesture to load video or Open Photo Gallery
    UITapGestureRecognizer *toggleCaption = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleCaption)];
    [self.storyWebView addGestureRecognizer:toggleCaption];
    
    
}
-(DetailViewModel*)detailViewModel {
    if (!_detailViewModel) {
        _detailViewModel = [[DetailViewModel alloc] init];
    }
    return _detailViewModel;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   }

-(void)viewDidAppear:(BOOL)animated{
    
    if (self.storyModelItem.storyModel.facebookCommentCount <= MNIMaxFBCommentsCount) {
    NSString *stoyUrlWithGraphApi = [NSString stringWithFormat:@"https://graph.facebook.com/?ids=%@",self.storyModelItem.storyModel.url];
    self.downloader = [[MNIURLDownloader alloc] initWithSession:nil];
    __weak MNIStoryViewController *weakSelf = self;
    [self.downloader downloadDataFromUrl:[NSURL URLWithString:stoyUrlWithGraphApi] withSuccessBlock:^(NSData *data) {
        NSError *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (!error) {
            weakSelf.storyModelItem.storyModel.facebookCommentCount = [[[[result objectForKey:weakSelf.storyModelItem.storyModel.url.absoluteString] objectForKey:@"share"] objectForKey:@"comment_count"] integerValue];
            dispatch_async( dispatch_get_main_queue(), ^{
                [weakSelf updateFacebookCommentCount];
            });
        }
       } andFailureBlock:^(NSError *error) {
            dispatch_async( dispatch_get_main_queue(), ^{
              [weakSelf updateFacebookCommentCount];
            });
    }];
    }
    else{
        [self updateFacebookCommentCount];
    }
 }

-(void)updateFacebookCommentCount{
    if ([self.delegate respondsToSelector:@selector(facebookCommentsCount:)]) {
        [self.delegate facebookCommentsCount:self.storyModelItem.storyModel.facebookCommentCount];
    }
}
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    
    //change aspect ratio for standard story imageView
    if (self.storyModelItem.normalItemSubtype != MasterViewModelNormalItemTypeTopStory) {
        CGFloat factor = self.view.frame.size.height > self.view.frame.size.width ? self.view.frame.size.width : self.view.frame.size.height;
        CGFloat newConstant = factor - (factor*MNIStandardStoryImageAspectRatio);
        if (newConstant != self.aspectRatioConstraint.constant) {
            self.aspectRatioConstraint.constant = newConstant;
        }
        if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular && self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
            if (newConstant != self.bottomConstraint.constant) {
                self.bottomConstraint.constant = newConstant;
            }
        }
    }
    
    //update constraits for ipad pro
    if (iPadProPortrait || iPadProLanscape)
        [self updateConstraintsforIpadPro];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.downloader cancel];
    self.downloader = nil;
}

-(void)updateConstraintsforIpadPro{
    
    if (self.storyModelItem.normalItemSubtype != MasterViewModelNormalItemTypeTopStory)
    {
        CGFloat factor = self.view.frame.size.height > self.view.frame.size.width ? self.view.frame.size.width : self.view.frame.size.height;
        CGFloat newConstant = factor - (factor*MNIStandardStoryImageAspectRatio);
        
        //maintain the aspect ratio 3:2 on large screen and the image should fit both left and right side.
        if (iPadProLanscape)
        {
            if(self.bottomConstraint.constant!= newConstant-85)
                self.bottomConstraint.constant = newConstant-85;
        }
        else
        {
            if (self.bottomConstraint.constant!= newConstant)
                self.bottomConstraint.constant = newConstant;
        }
    }
    else
    {
        //maintain the aspect ratio 1:1 on iPad pro and the image should fit both left and right side.
        if (iPadProLanscape)
        {
            if (self.leadTextBottomConstraint.constant != iPadProTopLinesBottomConstraint)
                self.leadTextBottomConstraint.constant = iPadProTopLinesBottomConstraint;
            
            //Keep the lead text visible in iPad Pro
            if (self.bottomConstraint.constant != -100)
                self.bottomConstraint.constant = -100;
        }
        else
        {
            if (self.leadTextBottomConstraint.constant != iPadTopLinesBottomConstraint)
                self.leadTextBottomConstraint.constant = iPadTopLinesBottomConstraint;
            
            //Keep the lead text visible in iPad Pro
            if (self.bottomConstraint.constant != -64)
                self.bottomConstraint.constant = -64;
        }
    }
}

-(void)loadPhotoGalleryIcon:(MNIStoryModel*)storyModel{
    self.isToggleVideo = NO;
    self.galleryview.hidden = NO;
    self.videoiconImg.hidden =YES;
    
    //Check the gallery images count
    if (storyModel.gallery_photos.count>0) {
        //Display number of images
        self.galleryCountLabel.text = [self.detailViewModel setGalleryTextCount:storyModel.gallery_photos.count];
        self.lblTrailingconstraint.constant = 8;
    }
    else{
        //Single lead image
        self.lblTrailingconstraint.constant = 4;
    }
    
    //Display background color for Standard story gallery icon
    if (self.storyModelItem.normalItemSubtype == MasterViewModelNormalItemTypeTopStory) {
        self.galleryview.backgroundColor = [UIColor clearColor];
    }
    else{
        self.galleryview.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    }
}
-(void)displayVideoIcon{
    self.isToggleVideo = YES;
    self.galleryview.hidden = YES;
    self.videoiconImg.hidden = NO;
}
-(void)toggleCaption
{
    if(self.isToggleVideo) {
        // TO DO loading video
    }
    else if (self.isToggleVideo == NO){
        // TO DO loading image gallery
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //set content inset and offset to webview
    self.storyWebView.scrollView.contentInset = [self.detailViewModel setContentInset:self.topStoryView.frame.size.height];
    [self.storyWebView.scrollView setContentOffset:[self.detailViewModel setContentOffset:self.topStoryView.frame.size.height]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark <UIWebViewDelegate>
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if ([[[request URL] scheme] isEqualToString:@"ios"]) {
            NSString *customLink = [[[request URL] resourceSpecifier] stringByReplacingOccurrencesOfString:@"//" withString:@""];
            
            if ([customLink containsString:@"next_story"]) {
                //do nothing
                [self.delegate performSelector:@selector(scrollToNextPage)];
                
            }
            
        }
        return NO;
    }
    return true;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //Set Alpha value
    CGFloat scrollOffset = -scrollView.contentOffset.y;
    CGFloat yPos = scrollOffset -self.topStoryView.frame.size.height;
    CGFloat alpha=1.0-(-yPos/self.topStoryView.frame.size.height)*alphaValue;
    
    /*Move the subviews when scroll up and down*/
    for (UIView *subview in self.topStoryView.subviews) {
        CGRect rect = subview.frame;
        float getfloat  = [[self.previousOffsetDictonary objectForKey:[NSNumber numberWithInteger:subview.tag]] floatValue] ;
        if (subview == self.storyImageView) {
            rect.origin.y += (getfloat - scrollView.contentOffset.y)/leadImageScrollOffset;
        }
        else{
            rect.origin.y += getfloat - scrollView.contentOffset.y;
            subview.alpha = alpha;
        }
        [self.previousOffsetDictonary setObject:[NSNumber numberWithFloat:scrollView.contentOffset.y] forKey:[NSNumber numberWithInteger:subview.tag]];
        subview.frame = rect;
    }
    
    
    //Parallax Effect when scroll down
    if (scrollView.contentOffset.y+self.topStoryView.frame.size.height < 0) {
        self.storyImageviewBottomConstraint.constant =scrollView.contentOffset.y+self.topStoryView.frame.size.height;
        self.galleryIconbottomConstraint.constant = scrollView.contentOffset.y+self.topStoryView.frame.size.height;
        self.iPhoneheadLineBottomConstraint.constant = scrollView.contentOffset.y+self.topStoryView.frame.size.height+50;
        if (iPadProLanscape){
            self.leadTextBottomConstraint.constant = scrollView.contentOffset.y+self.topStoryView.frame.size.height+iPadProTopLinesBottomConstraint;
        }
        else{
            self.leadTextBottomConstraint.constant = scrollView.contentOffset.y+self.topStoryView.frame.size.height+iPadTopLinesBottomConstraint;
        }
        [self.view layoutIfNeeded];
    }
}

@end
