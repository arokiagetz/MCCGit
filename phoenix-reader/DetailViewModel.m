//
//  DetailViewModel.m
//  phoenix-reader
//
//  Created by Dibya Pattanaik on 6/16/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "DetailViewModel.h"
#import "MILog.h"
#import "NSDate+helper.h"
#import "NSString+helper.h"

@interface DetailViewModel()
@property(assign,nonatomic)BOOL isVerticalRegularSizeClass;
@property(assign,nonatomic)BOOL isHorizontalRegularSizeClass;
@end

@implementation DetailViewModel


-(NSString *) buildStoryContentStringFromStoryModel:(MasterViewModelItem *)storyModelItem withTraitCollection:(UITraitCollection*)traitCollection andNextStory:(MasterViewModelItem *)nextStoryModelItem
{
    self.isVerticalRegularSizeClass = traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular;
    self.isHorizontalRegularSizeClass =traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular;
    
    NSString *htmlFileName = (self.isVerticalRegularSizeClass && self.isHorizontalRegularSizeClass) ? @"NewStory_tablet" : @"NewStory";
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:htmlFileName ofType:@"html"];
    _htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    // checking for existance of lead image
    if (storyModelItem.storyModel.thumbnail) {
        self.isLeadImageExist = YES;
    }
    else{
        self.isLeadImageExist = NO;
    }
    if (self.isVerticalRegularSizeClass && self.isHorizontalRegularSizeClass) {
        // wRegular hRegular (iPad with single app in use)
        if (!self.isLeadImageExist || !(storyModelItem.normalItemSubtype == MasterViewModelNormalItemTypeTopStory)) { //Top Story Without Leading image AND Standard Story
            //TOPIC TAG
            if (storyModelItem.storyModel.topic) {
                _htmlString = [self makeTopicTextReplacements:_htmlString topicTxt:storyModelItem.storyModel.topic];
            }
            
            // TITTLE TAG
            _htmlString = [_htmlString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<!--%@",@"ipadheadline"] withString:@""];
            _htmlString = [_htmlString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@-->",@"ipadheadline"] withString:@""];
            _htmlString = [_htmlString stringByReplacingOccurrencesOfString:@"%title%" withString:storyModelItem.storyModel.title!=nil? storyModelItem.storyModel.title : @""];
            // Some stories dont have lead text
            if (storyModelItem.storyModel.leadtext) {
                // LEADTEXT TAG
                _htmlString = [self makeLeadTextReplacements:_htmlString leadTxt:storyModelItem.storyModel.leadtext];
                
            }
        }
    }
    else {
        if (!self.isLeadImageExist || !(storyModelItem.normalItemSubtype == MasterViewModelNormalItemTypeTopStory)){ //Top Story Without Leading image AND Standard Story
            //TOPIC TAG
            if (storyModelItem.storyModel.topic) {
                _htmlString = [self makeTopicTextReplacements:_htmlString topicTxt:storyModelItem.storyModel.topic];
            }
            
            // TITTLE TAG
            _htmlString = [_htmlString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<!--%@",@"iphoneheadline"] withString:@""];
            _htmlString = [_htmlString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@-->",@"iphoneheadline"] withString:@""];
            _htmlString = [_htmlString stringByReplacingOccurrencesOfString:@"%title%" withString:storyModelItem.storyModel.title!=nil? storyModelItem.storyModel.title : @""];
        }
        // Some stories dont have lead text
        if (storyModelItem.storyModel.leadtext) {
            // LEADTEXT TAG
            _htmlString = [self makeLeadTextReplacements:_htmlString leadTxt:storyModelItem.storyModel.leadtext];
            
        }
    }
    
    // Check to see if the dateline object exists
    if(storyModelItem.storyModel.dateline)
    {
        // DATELINE TAG - Like "MIAMI-DADE COUNTY"
        _htmlString = [self injectDateline:storyModelItem.storyModel.dateline intoHTML:_htmlString];
    }
    
    
    // AUTHOR TAG
    //Author name and email id seperation
    
    
    //FIXME: Check with API team regarding author/email format
    
    if ([storyModelItem.storyModel.author rangeOfString:@" "].location != NSNotFound) {
        NSRange range = [storyModelItem.storyModel.author rangeOfString:@" " options:NSBackwardsSearch];
        NSString *authorEmail = [storyModelItem.storyModel.author substringFromIndex:range.location+1];
        NSString *authorName= [storyModelItem.storyModel.author substringToIndex: range.location];
        
        _htmlString = [_htmlString stringByReplacingOccurrencesOfString:@"%authorName%" withString:[authorName uppercaseString]!=nil? [authorName uppercaseString] : @""];
        
        _htmlString = [_htmlString stringByReplacingOccurrencesOfString:@"%authorEmail%" withString:[authorEmail uppercaseString]!=nil? [authorEmail uppercaseString] : @""];
    } else {
        _htmlString = [_htmlString stringByReplacingOccurrencesOfString:@"%authorName%" withString:[storyModelItem.storyModel.author uppercaseString]!=nil? [storyModelItem.storyModel.author uppercaseString] : @""];
    }
    
    
    
    
    // PUBLICATION DATE TAG
    _htmlString = [_htmlString stringByReplacingOccurrencesOfString:@"%pubdate%" withString:[NSDate MNITimeAgoSinceDate:storyModelItem.storyModel.published_date]!=nil? [NSDate MNITimeAgoSinceDate:storyModelItem.storyModel.published_date]: @""];
    if (storyModelItem.storyModel.publication)
    {
        //LOCATION TAG
        _htmlString = [_htmlString stringByReplacingOccurrencesOfString:@"%locationart%" withString:storyModelItem.storyModel.publication!=nil? storyModelItem.storyModel.publication : @""];
    }
    
    
    // // Some stories dont have content node
    if (storyModelItem.storyModel.content)
    {
        // STORY CONTENT TAG
        _htmlString = [_htmlString stringByReplacingOccurrencesOfString:@"%content%" withString:storyModelItem.storyModel.content];
    }
    
    // TODO - Footer display for next Story to be added latter
    if (nextStoryModelItem != nil) {
        _htmlString = [_htmlString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<!--%@",@"footer"] withString:@""];
        _htmlString = [_htmlString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@-->",@"footer"] withString:@""];
        _htmlString = [_htmlString stringByReplacingOccurrencesOfString:@"%next_headline%" withString:nextStoryModelItem.storyModel.title];

    }
    
    return _htmlString;
}
-(NSString *)makeLeadTextReplacements:(NSString *)storyHTML leadTxt:(NSArray *) leadTextArray
{
    //  NSArray *toplines = self.itemData[@"leadtext"];
    if(leadTextArray && [leadTextArray isKindOfClass:[NSArray class]])
    {
        NSInteger index = 1;
        for (MNIStoryLeadtextModel *topline in leadTextArray){
            NSString *replacementString = [NSString stringWithFormat:@"topline%ld",(long)index];
            storyHTML = [storyHTML stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<!--%@",replacementString] withString:@""];
            storyHTML = [storyHTML stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@-->",replacementString] withString:@""];
            storyHTML = [storyHTML stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%%%@%%",replacementString] withString:topline.text];
            index++;
        }
    }
    
    return storyHTML;
}

-(NSString *)makeTopicTextReplacements:(NSString *)storyHTML topicTxt:(NSString *) topText
{
    NSString *replacementString = [NSString stringWithFormat:@"topic"];
    storyHTML = [storyHTML stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<!--%@",replacementString] withString:@""];
    storyHTML = [storyHTML stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@-->",replacementString] withString:@""];
    storyHTML = [storyHTML stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%%%@%%",replacementString] withString:topText!=nil? topText : @""];
    return storyHTML;
}

-(NSString *)injectDateline:(NSString *)dateline intoHTML:(NSString *)html
{
    /*
     html encoding for accent marks and tildes for capital letters shoud be in lowercase
     for "é" should be "&eacute;", for "É" should be "&Eacute;", this method also work for (Ñ:&Ntilde;) an others.
     */
    dateline = [NSString replaceStringCapitalHtmlEncoding:dateline];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(.*?)(<p>)"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    
    NSArray *matches = [regex matchesInString:html options:0 range:NSMakeRange(0, [html length])];
    
    NSTextCheckingResult *result = [matches firstObject];
    
    if([result numberOfRanges] == 3)
    {
        html = [html stringByReplacingCharactersInRange:[result rangeAtIndex:2] withString:[NSString stringWithFormat:@"<p><b><span id=\"dateline\">%@</span></b><br/>",dateline]];
    }
    else
        html = [html stringByReplacingOccurrencesOfString:@"%dateline%" withString:dateline];
    
    return html;
    
}

-(UIEdgeInsets)setContentInset:(CGFloat)heightOfImgView
{
    // passing content inset for webview based on lead image existance
    if (self.isLeadImageExist) {
        
        return UIEdgeInsetsMake(heightOfImgView , 0, 0, 0);
    }
    
    return UIEdgeInsetsZero;
}
-(CGPoint)setContentOffset:(CGFloat)heightOfView{
    //passing the content offset for webview based on lead image existence
    if (self.isLeadImageExist) {
        
        return CGPointMake(0, -heightOfView);
    }
    return CGPointZero;
}
-(NSMutableAttributedString*)setTopLineText :(NSArray*)leadtext{
     //passing the TopLines
    NSMutableAttributedString * topLineText = [[NSMutableAttributedString alloc] init];
    if ([leadtext count] > 0) {
        for (MNIStoryLeadtextModel *topline in leadtext){
            NSMutableAttributedString *attr =
            [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"●%@\n",topline.text] ];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            
            //set line spacing to Toplines
            [paragraphStyle setLineSpacing:10];
            
            [paragraphStyle setAlignment:NSTextAlignmentCenter];
            [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attr length])];
            [topLineText appendAttributedString:attr];
        }
        return topLineText;
    }
    [topLineText appendAttributedString:[[NSAttributedString alloc] initWithString: @""]];
    
    return topLineText;
    
}
-(NSString*)setTopicText:(NSString*)topic {
    //passing the topic text
    return [NSString stringWithFormat:@"  %@  ",[topic uppercaseString]];
}
-(NSMutableAttributedString*)setHeadLineText:(NSString*)headLine{
    //passing the HeadLine
    NSMutableAttributedString *attr =
    [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@  ",headLine] ];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:10];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attr length])];
    return attr;
}

-(UIFont*)setHeadLineTextFont{
    //set font for HeadLine
    UIFont *font = (self.isVerticalRegularSizeClass && self.isHorizontalRegularSizeClass) ? [UIFont fontWithName:@"McClatchySlab-Medium" size:28] :[UIFont fontWithName:@"McClatchySlab-Medium" size:23];
    return font;
}
-(UIFont*)setTopicTextFont{
    //set font for Topic
    UIFont *font = [UIFont fontWithName:@"McClatchySansCond-Demi" size:12];
    return font;
}
-(UIFont*)setTopLineTextFont{
    //set font for TopLine
    UIFont *font = [UIFont fontWithName:@"McClatchySans-Regular" size:15];
    return font;
}
-(CAGradientLayer*)addGradientsToImageView:(CAGradientLayer *)gradientLayer
{
    //Apply Gradient for TopStory Lead Image
    UIColor *topColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
    UIColor *bottomColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.90f];
    gradientLayer.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    gradientLayer.locations = @[@0.0, @1.0];
    return gradientLayer;
}
-(MNIStoryModel*)leadAssetmodel:(MNIStoryAssetsModel*)assets{
    //handling lead Assets
    NSArray<NSString *> *videoAssetTypes = @[ @"videoStory", @"videoFile", @"videoIngest" ];
    NSArray<NSString *> *photoAssetTypes = @[ @"gallery", @"picture" ];
    //Lead Asset
    if (assets.leadAssets.count>0) {
        for (NSUInteger i = 0; i < assets.leadAssets.count; i++) {
            MNIStoryModel *model = (MNIStoryModel*)assets.leadAssets[i];
            if ([videoAssetTypes containsObject:model.asset_type]) {
                //handle video
                model.normalItemSubtype = StoryAssetsModelNormalItemTypeVideoGalleryStory;
                return model;
            }
            else if ([photoAssetTypes containsObject:model.asset_type]) {
                //handle gallery
                model.normalItemSubtype = StoryAssetsModelNormalItemTypePhotoGalleryStory;
                return model;
            }
        }
    }
    return nil;
}
-(NSUInteger)leadSectionStoryAssestType:(MNIStoryModel*)storyModel{
    /* Handling leadSectionStory Asset Type */
    NSArray<NSString *> *videoAssetTypes = @[ @"videoStory", @"videoFile", @"videoIngest" ];
    NSArray<NSString *> *photoAssetTypes = @[ @"gallery", @"picture" ];
    if ([videoAssetTypes containsObject:storyModel.asset_type]) {
        //handle video
        return storyModel.normalItemSubtype = StoryAssetsModelNormalItemTypeVideoGalleryStory;
    }
    else if ([photoAssetTypes containsObject:storyModel.asset_type]) {
        //handle gallery
        return storyModel.normalItemSubtype = StoryAssetsModelNormalItemTypePhotoGalleryStory;
    }
    return 0;
}
-(NSString*)setGalleryTextCount:(NSUInteger)galleryPhotos{
    if (galleryPhotos>99) {
        //more than 99 images
        return [NSString stringWithFormat:@"99+ PHOTOS"];
    }
    return [NSString stringWithFormat:@"%ld PHOTOS",galleryPhotos];
}
@end
