//
//  NSManagedObject+Helpers.h
//  phoenix-reader
//
//  Created by Scott Ferwerda on 3/17/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Helpers)

+ (NSString *)entityName;
+ (instancetype)insertNewObjectInContext:(NSManagedObjectContext *)context;

@end
