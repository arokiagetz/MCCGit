//
//  MNIStoryManager.h
//  phoenix-reader
//
//  Created by Yann Duran on 3/17/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Task/Task.h>
#import "MNIURLDownloader.h"
#import "MNIStory.h"

@interface MNIStoryManager : NSObject <MNIURLDownloaderDelegate, TSKWorkflowDelegate, TSKTaskDelegate>

@property (strong, nonatomic) TSKWorkflow *downloadWorkflow;
@property (strong, nonatomic) MNIURLDownloader* downloader;
@property (strong, nonatomic) NSFetchedResultsController* fetchedResultsController;

- (NSFetchedResultsController*)fetchedResultsControllerForStoriesInSectionIds:(NSArray *)sectionIds delegate:(id<NSFetchedResultsControllerDelegate>)delegate;
- (void)downloadSectionWithSectionIds:(NSArray *)sectionIds completion:(MNIURLDownloaderCompletionBlock)completionBlock;

@end
