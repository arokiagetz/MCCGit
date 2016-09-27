//
//  MNISectionFrontStoryCell.m
//  phoenix-reader
//
//  Created by Scott Ferwerda on 4/6/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNISectionFrontStoryCell.h"
#import "MNIGradientImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+ColorHelpers.h"
#import "MNIUITheme.h"
#import "NSDate+helper.h"
#import "MILog.h"
#import "UIImage+helper.h"
#import "MNIThemeManager.h"


#define NORMAL_CELL_HEADLINE_FONT_NAME @"McClatchySans-Regular"
#define NORMAL_CELL_HEADLINE_FONT_SIZE 16.0
#define GALLERY_HEADLINE_NUMBEROFLINES 3.0

@interface MNISectionFrontStoryCell ()

@property (weak, nonatomic) IBOutlet MNIGradientImageView *storyImage;
@property (weak, nonatomic) IBOutlet UIImageView *photoVideoIconView;
@property (weak, nonatomic) IBOutlet UIImageView *shadowImage;

@property (strong, nonatomic) UIFont *normalCellHeadlineFont;

@property (strong, nonatomic) UIColor *normalBodyBackgroundColor;
@property (strong, nonatomic) UIColor *normalHeadlineTextColor;
@property (strong, nonatomic) UIColor *normalFooterTextColor;
@property (strong, nonatomic) UIColor *selectedBodyBackgroundColor;
@property (strong, nonatomic) UIColor *selectedHeadlineTextColor;
@property (strong, nonatomic) UIColor *selectedFooterTextColor;

@property (nonatomic, strong) MasterViewModelItem *vmItem;

@end

@implementation MNISectionFrontStoryCell

// synthesize methods specified in cell protocol
@synthesize bodyView, headlineLabel, topicLabel, relativeTimeLabel, selectionBarView, selectionBarDivot, themeIdentifier;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self setupGradientLayer];
    [self clearIBLayoutPlaceholders];
    // TODO: this font definition may need to be constructed from values in the bootstrap config
    self.normalCellHeadlineFont = [UIFont fontWithName:NORMAL_CELL_HEADLINE_FONT_NAME size:NORMAL_CELL_HEADLINE_FONT_SIZE];
    
}

- (void)prepareForReuse
{
    [self clearIBLayoutPlaceholders];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat maxWidth = CGRectGetWidth(self.frame);
    self.headlineLabel.preferredMaxLayoutWidth = maxWidth - 32;
    
    [super layoutSubviews];
}

- (void)setupGradientLayer
{
    if (self.storyImage != nil) {
        UIColor *topColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
        UIColor *bottomColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.90f];
        self.storyImage.gradientLayer.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
        self.storyImage.gradientLayer.locations = @[@0.0, @1.0];
    }
}

- (void)setColorSchemeForItemSubtype:(MasterViewModelNormalItemType)itemSubtype {
    
    NSString *normalBodyBackgroundHexColor;
    NSString *normalHeadlineTextHexColor;
    NSString *normalFooterBoxTextHexColor;
    
    NSString *selectedBodyBackgroundHexColor;
    NSString *selectedHeadlineTextHexColor;
    NSString *selectedFooterBoxTextHexColor;
    
    
    /*Apply theme for cell shadow image*/
    
    BOOL isLightTheme = [[MNIThemeManager sharedThemeManager] isLightTheme];

    if (isLightTheme) {
        self.shadowImage.image = [UIImage imageNamed:@"cellDropShadow"];
    } else {
        self.shadowImage.image = [UIImage imageNamed:@"cellDropShadowDark"];
    }

    if (itemSubtype == MasterViewModelNormalItemTypeTopStory) {
        
        normalBodyBackgroundHexColor = isLightTheme ? MNIUIColorLightWhite : MNIUIColorWhite;
        normalHeadlineTextHexColor = isLightTheme ? MNIUIColorWhite : MNIUIColorLightWhite;
        normalFooterBoxTextHexColor = MNIUIColorselectedFooterColor;
        
        selectedBodyBackgroundHexColor = MNIUIColorVideoBodyBgColor;
        
    } else if (itemSubtype == MasterViewModelNormalItemTypePhotoGalleryStory ||
             itemSubtype == MasterViewModelNormalItemTypeVideoGalleryStory ||
             itemSubtype == MasterViewModelNormalItemTypeSectionLeadStory) {
        
        normalBodyBackgroundHexColor = MNIUIColorBlack;
        normalHeadlineTextHexColor = MNIUIColorWhite;
        normalFooterBoxTextHexColor = MNIUIColorNormalFooterColor;
        
        selectedBodyBackgroundHexColor = MNIUIColorAllBodyBgColor;
        
    } else {
        
        normalBodyBackgroundHexColor = isLightTheme ? MNIUIColorWhite : MNIUIColorLightWhite;
        normalHeadlineTextHexColor = isLightTheme ? MNIUIColorLightWhite : MNIUIColorWhite;
        normalFooterBoxTextHexColor = MNIUIColorNormalFooterColor;
        
        selectedBodyBackgroundHexColor = MNIUIColorVideoBodyBgColor;
        
    }
    selectedHeadlineTextHexColor = MNIUIColorWhite;
    selectedFooterBoxTextHexColor = MNIUIColorselectedFooterColor;
    
    ////
    
    /*Apply cell background color, Headline color and footer color depends on theme*/
    self.normalBodyBackgroundColor = [UIColor colorWithRGBAString:normalBodyBackgroundHexColor];
    self.normalHeadlineTextColor = [UIColor colorWithRGBAString:normalHeadlineTextHexColor];
    self.normalFooterTextColor = [UIColor colorWithRGBAString:normalFooterBoxTextHexColor];
    
    self.selectedBodyBackgroundColor = [UIColor colorWithRGBAString:selectedBodyBackgroundHexColor];
    self.selectedHeadlineTextColor = [UIColor colorWithRGBAString:selectedHeadlineTextHexColor];
    self.selectedFooterTextColor = [UIColor colorWithRGBAString:selectedFooterBoxTextHexColor];
}

- (void)showStoryImageGradient:(BOOL)visible
{
    self.storyImage.gradientLayer.hidden = (visible == NO);
}

- (void)configureCellWithVMItem:(MasterViewModelItem *)vmItem
{
    self.vmItem = vmItem;
    
    MasterViewModelNormalItemType itemSubtype = vmItem.normalItemSubtype;
    MNIStoryModel *story = vmItem.storyModel;
    [self setColorSchemeForItemSubtype:itemSubtype];
    if (itemSubtype == MasterViewModelNormalItemTypeTopStory) {
        // top story
        [self showStoryImageGradient:NO];
        self.photoVideoIconView.hidden = YES;
    }
    else if (itemSubtype == MasterViewModelNormalItemTypeSectionLeadStory) {
        // lead story in a section
        [self showStoryImageGradient:YES];
        self.photoVideoIconView.hidden = YES;
        // **** MOBI-2530 feature/2530-image_cell_headline_displaying
        self.headlineLabel.numberOfLines = GALLERY_HEADLINE_NUMBEROFLINES;
    }
    else if (itemSubtype == MasterViewModelNormalItemTypeVideoGalleryStory ||
             itemSubtype == MasterViewModelNormalItemTypePhotoGalleryStory) {
        // photo/video gallery story
        [self showStoryImageGradient:YES];
        // TODO: if this is a photo/video gallery story, set appropriate icon and unhide
        self.photoVideoIconView.hidden = NO;
        // **** MOBI-2530 feature/2530-image_cell_headline_displaying
        self.headlineLabel.numberOfLines = GALLERY_HEADLINE_NUMBEROFLINES;
        //        MILogDebug(@"thumbnail = %@", story.thumbnail);
        NSURL *storyThumbnailURL = [NSURL URLWithString:story.thumbnail];
        [self.storyImage sd_setImageWithURL:storyThumbnailURL placeholderImage:[UIImage imageNamed:@"placeholder320x184"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //
        }];
        self.photoVideoIconView.hidden = NO;
        if (itemSubtype == MasterViewModelNormalItemTypeVideoGalleryStory) {
            self.photoVideoIconView.image = [UIImage imageNamed:@"playIcon"];
        }
        else {
            self.photoVideoIconView.image = [UIImage imageNamed:@"cameraIcon"];
        }
    }
    else {
        // generic story
        [self showStoryImageGradient:NO];
        self.photoVideoIconView.hidden = YES;
    }
    
    NSString *headlinePlainText = story.title;
    // add formatting
    
    //FIXME: Check what to do if title is nil
    if (!headlinePlainText) {
        headlinePlainText = story.summary;
    }
    
    NSMutableAttributedString *headlineAttributedText = [[NSMutableAttributedString alloc] initWithString:headlinePlainText];
    NSRange headlineAttributedTextRangeAll = NSMakeRange(0, headlineAttributedText.length);
    UIFont *headlineFont = self.normalCellHeadlineFont;
    [headlineAttributedText addAttribute:NSFontAttributeName value:headlineFont range:headlineAttributedTextRangeAll];
    NSMutableParagraphStyle *headlineStyle = [[NSMutableParagraphStyle alloc] init];
    CGFloat headlineFontSize = headlineFont.pointSize;
    CGFloat headlineSpacing = headlineFontSize * 0.25;
    [headlineStyle setLineSpacing:headlineSpacing];
    [headlineStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [headlineAttributedText addAttribute:NSParagraphStyleAttributeName value:headlineStyle range:headlineAttributedTextRangeAll];
    self.headlineLabel.attributedText = headlineAttributedText;
    
    self.topicLabel.text = [story.topic uppercaseString];
    
    NSString *prettyTimestamp = [NSDate MNITimeAgoSinceDate:story.published_date];
    self.relativeTimeLabel.text = [prettyTimestamp uppercaseString];
}
- (void)updateThumbnailInView
{
    MNIStoryModel *story = self.vmItem.storyModel;
    
    if (self.storyImage != nil) {
        UIImage *placeholderImage = [UIImage imageNamed:@"placeholder320x184"];
        if (story.thumbnail.length > 0) {
            //            MILogDebug(@"thumbnail url = %@", story.thumbnail);
            NSURL *storyThumbnailURL = [NSURL URLWithString:story.thumbnail];
            [self.storyImage sd_setImageWithURL:storyThumbnailURL placeholderImage:placeholderImage];
        }
        else {
            self.storyImage.image = placeholderImage;
        }
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    self.selectionBarView.hidden = (selected == NO);
    self.selectionBarDivot.hidden = (selected == NO);
    
    UIColor *bodyBackgroundColor = (selected ? self.selectedBodyBackgroundColor : self.normalBodyBackgroundColor);
    UIColor *headlineTextColor = (selected ? self.selectedHeadlineTextColor : self.normalHeadlineTextColor);
    UIColor *footerTextColor = (selected ? self.selectedFooterTextColor : self.normalFooterTextColor);
    
    void (^animationsBlock)(MNISectionFrontStoryCell *) = ^(MNISectionFrontStoryCell *blockSelf) {
        self.bodyView.backgroundColor = bodyBackgroundColor;
        self.headlineLabel.textColor = headlineTextColor;
        self.selectionBarDivot.tintColor = bodyBackgroundColor;
        self.topicLabel.textColor = footerTextColor;
        self.relativeTimeLabel.textColor = footerTextColor;
    };
    
    // TODO: rather than always forcing an animation here, we should change the caller to request animation when appropriate
    //    if (animated) {
    [UIView animateWithDuration:0.3 animations:^{
        __weak MNISectionFrontStoryCell *weakSelf = self;
        animationsBlock(weakSelf);
    }];
    //    }
    //    else {
    //        animationsBlock(self);
    //    }
    
    if (selected) {
        if (self.storyImage != nil) {
            self.storyImage.image = [UIImage convertImageToGrayScale:self.storyImage.image];
            
            if (blueLayer == nil)
                blueLayer = [[CALayer alloc] init];
            blueLayer.frame = self.storyImage.frame;
            blueLayer.backgroundColor = [[UIColor colorWithRed:0.00 green:0.58 blue:0.82 alpha:0.5] CGColor];
            [self.storyImage.layer addSublayer:blueLayer];
            
        }
    } else {
        [blueLayer removeFromSuperlayer];
        [self updateThumbnailInView];
    }
}

- (void)clearIBLayoutPlaceholders
{
    self.headlineLabel.text = @"";
    self.topicLabel.text = @"";
    self.relativeTimeLabel.text = @"";
    self.imageView.image = nil;
}




@end
