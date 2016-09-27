//
//  MTLModel+NSNullRemoval.h
//  Reader
//
//  Created by Scott Ferwerda on 2/23/16.
//  Copyright © 2016 McClatchy Interactive. All rights reserved.
//

#import "MTLModel.h"

@interface MTLModel (NSNullRemoval)

- (void)convertNSNullsToNils;

@end
