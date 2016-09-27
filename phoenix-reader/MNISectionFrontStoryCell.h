//
//  MNISectionFrontStoryCell.h
//  phoenix-reader
//
//  Created by Scott Ferwerda on 4/6/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNISectionFrontStoryCellProtocol.h"

@interface MNISectionFrontStoryCell : UITableViewCell <MNISectionFrontStoryCellProtocol>
{
    CALayer *blueLayer;
}

@end
