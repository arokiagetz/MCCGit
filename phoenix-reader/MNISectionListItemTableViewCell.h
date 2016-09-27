//
//  MNISectionListItemTableViewCell.h
//  phoenix-reader
//
//  Created by Scott Ferwerda on 5/10/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNISectionListItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *cellSeparatorView;

@property (strong, nonatomic) NSString *themeIdentifier;

@end
