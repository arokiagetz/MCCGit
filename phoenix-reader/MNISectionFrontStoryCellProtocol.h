//
//  MNISectionFrontStoryCellProtocol.h
//  phoenix-reader
//
//  Created by Scott Ferwerda on 4/6/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MasterViewModels.h"

@protocol MNISectionFrontStoryCellProtocol <NSObject>

@property (weak, nonatomic) IBOutlet UIView *bodyView;
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UILabel *relativeTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *selectionBarView;
@property (weak, nonatomic) IBOutlet UIImageView *selectionBarDivot;

@property (strong, nonatomic) NSString *themeIdentifier;

- (void)configureCellWithVMItem:(MasterViewModelItem *)vmItem;

@end
