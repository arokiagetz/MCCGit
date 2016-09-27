//
//  MNISectionHandler.h
//  phoenix-reader
//
//  Created by SANDEEP on 9/21/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MNIURLDownloader.h"
#import "MNISection.h"
#import "NSManagedObject+Helpers.h"


@interface MNISectionManager : NSObject

- (void)getUpdatedSectionsforSectionID:(NSArray *)sectionIDs withComplitionHandeler:(void(^)(NSArray *fetchedSections, NSError *error, BOOL isDownloading))complitionHandler;

@end
