//
//  DetailViewModel.h
//  phoenix-reader
//
//  Created by Dibya Pattanaik on 6/16/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNIStoryModel.h"
#import "MNIStoryManager.h"
#import "MasterViewModels.h"


@interface DetailViewModel : NSObject

@property (nonatomic) NSString *htmlString;
@property (nonatomic) BOOL  isLeadImageExist;

-(NSString *) buildStoryContentStringFromStoryModel:(MasterViewModelItem *)storyModelItem withTraitCollection:(UITraitCollection*)traitCollection andNextStory:(MasterViewModelItem *)nextStoryModelItem;
-(UIEdgeInsets)setContentInset:(CGFloat)heightOfImgView;
-(CGPoint)setContentOffset:(CGFloat)heightOfView;
-(UIFont*)setHeadLineTextFont;
-(UIFont*)setTopicTextFont;
-(UIFont*)setTopLineTextFont;
-(CAGradientLayer*)addGradientsToImageView:(CAGradientLayer*)gradientLayer;
-(NSMutableAttributedString*)setTopLineText :(NSArray*)leadtext;
-(NSString*)setTopicText:(NSString*)topic;
-(NSMutableAttributedString*)setHeadLineText:(NSString*)headLine;
-(MNIStoryModel*)leadAssetmodel:(MNIStoryAssetsModel*)assets;
-(NSString*)setGalleryTextCount:(NSUInteger)galleryPhotos;
-(NSUInteger)leadSectionStoryAssestType:(MNIStoryModel*)storyModel;
@end
