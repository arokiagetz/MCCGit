//
//  NSManagedObject+Helpers.m
//  phoenix-reader
//
//  Created by Scott Ferwerda on 3/17/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//
//  Taken from a blog post at http://www.jessesquires.com/swift-coredata-and-testing/

#import "NSManagedObject+Helpers.h"

@implementation NSManagedObject (Helpers)

+ (NSString *)entityName
{
    return NSStringFromClass([self class]);
}

+ (instancetype)insertNewObjectInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                         inManagedObjectContext:context];
}

@end
