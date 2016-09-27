//
//  MNISectionListOtherOptionsCell.h
//  phoenix-reader
//
//  Created by Scott Ferwerda on 5/27/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MNISectionListOtherOptionsCell;

@protocol MNISectionListOtherOptionsCellDelegate <NSObject>

- (void)sectionListOtherOptionsCell:(MNISectionListOtherOptionsCell *)otherOptionsCell didSelectOtherOptionWithIndex:(NSInteger)otherOptionIndex;

@end

@interface MNISectionListOtherOptionsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (weak,nonatomic) id<MNISectionListOtherOptionsCellDelegate> delegate;

@end
