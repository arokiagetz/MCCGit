//
//  MTLModel+NSNullRemoval.m
//  Reader
//
//  Created by Scott Ferwerda on 2/23/16.
//  Copyright © 2016 McClatchy Interactive. All rights reserved.
//

#import "MTLModel+NSNullRemoval.h"
#import <objc/runtime.h>

@implementation MTLModel (NSNullRemoval)

- (void)convertNSNullsToNils
{
    // find the NSNulls in our properties
    unsigned int numProperties;
    objc_property_t *properties = class_copyPropertyList([self class], &numProperties);
    for (unsigned int i = 0; i < numProperties; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:[NSString defaultCStringEncoding]];
        id propertyValue = [self valueForKey:propertyName];
        if ([propertyValue isKindOfClass:[NSNull class]]) {
            [self setValue:nil forKey:propertyName];
        }
        else if ([propertyValue isKindOfClass:[MTLModel class]]) {
            // recurse
            [(MTLModel *)propertyValue convertNSNullsToNils];
        }
    }
}

@end
