//
//  MNIStoryManager.m
//  phoenix-reader
//
//  Created by Yann Duran on 3/17/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNIStoryManager.h"
#import "MILog.h"
#import "MNIDataController.h"
#import "NSDate+helper.h"
#import "MNIServerConfigManager.h"
#import "MNISectionFrontViewController.h"

@implementation MNIStoryManager

- (MNIURLDownloader *)downloader
{
    if (_downloader == nil) {
        _downloader = [[MNIURLDownloader alloc] init];
    }
    return _downloader;
}

#pragma mark - Fetch Requests

- (NSFetchRequest *)fetchRequestForStoriesInSectionIds:(NSArray *)sectionIds withMOC:(NSManagedObjectContext *)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sectionId IN %@", sectionIds];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sectionDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sectionId" ascending:YES];
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"fetchedDate" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObjects:sectionDescriptor, descriptor, nil];
    
    [fetchRequest setSortDescriptors:descriptors];
    
    return fetchRequest;
}

- (NSFetchRequest *)fetchRequestForStoriesWithStoryIds:(NSArray *)storyIds withMOC:(NSManagedObjectContext *)moc
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"storyId IN %@",storyIds];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"fetchedDate" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObjects:descriptor, nil];
    
    [fetchRequest setSortDescriptors:descriptors];
    
    return fetchRequest;
}

#pragma mark - Fetch Result Controllers

- (NSFetchedResultsController*)fetchedResultsControllerForStoriesInSectionIds:(NSArray *)sectionIds delegate:(id<NSFetchedResultsControllerDelegate>)delegate
{
    NSManagedObjectContext *moc = [[MNIDataController sharedDataController] workerObjectContext];
    NSFetchRequest *fetchRequest = [self fetchRequestForStoriesInSectionIds:sectionIds withMOC:moc];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:@"sectionId" cacheName:nil];
    self.fetchedResultsController.delegate = delegate;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        MILogError(@"%@",error.localizedDescription);
        return nil;
    }
    
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        // nothing?, let's download
        [self downloadSectionWithSectionIds:sectionIds completion:^(NSData *data, NSError *error, BOOL success) {
       
        }];
    }
    
    return self.fetchedResultsController;
}

#pragma mark - Download

- (void)downloadSectionWithSectionIds:(NSArray *)sectionIds completion:(MNIURLDownloaderCompletionBlock)completionBlock {
    
    MNIServerConfigModel *configModel = [[MNIServerConfigManager sharedManager] serverConfigModel];
    NSString *baseUrl = configModel.apiInfo.baseUrl;
    MNIConfigSectionsInfoModel *sectionsInfo = configModel.sections_info;
    
    NSMutableString *sectioEndPointUrl = [NSMutableString stringWithFormat:@"%@v1/sections/",baseUrl];
    if (sectionIds.count == 1) {   
        MNIConfigSectionModel *sectionModel = [sectionsInfo modelForSectionWithID:sectionIds[0]];
        NSString *storyPerSectionLimit = [NSString stringWithFormat:@"%ld",configModel.sections_info.stories_shown_per_section];
        if (sectionModel.contentType && ![sectionModel.contentType isEqualToString:@"content"]) {
            [sectioEndPointUrl appendString:[NSString stringWithFormat:@"%@/contentType/%@/limit/%@",sectionIds[0],sectionModel.contentType,storyPerSectionLimit]];
        } else {
            [sectioEndPointUrl appendString:[NSString stringWithFormat:@"%@/limit/%@",sectionIds[0],storyPerSectionLimit]];
        }
    } else {
        
        for (NSString *sectionId in sectionIds) {
            MNIConfigSectionModel *sectionModel = [sectionsInfo modelForSectionWithID:sectionId];
            NSInteger storyPerSection = [sectionId isEqualToString:sectionsInfo.multisection.top_story_section_id] ? sectionsInfo.multisection.top_stories_shown : sectionsInfo.multisection.stories_shown;
            
            if (sectionModel.contentType && ![sectionModel.contentType isEqualToString:@"content"]) {
                [sectioEndPointUrl appendString:[NSString stringWithFormat:@"sectionId=%@,limit=%ld,contentType=%@;",sectionId,storyPerSection,sectionModel.contentType]];
            } else {
                [sectioEndPointUrl appendString:[NSString stringWithFormat:@"sectionId=%@,limit=%ld;",sectionId,storyPerSection]];
            }
        }
    }
    
    NSURL *urlToDownload = [NSURL URLWithString:sectioEndPointUrl];
    [self.downloader downloadDataFromUrl:urlToDownload withSuccessBlock:^(NSData *data) {
        [self didReceiveData:data completion:completionBlock];
    } andFailureBlock:^(NSError *error) {
        [self didFailWithError:error completion:completionBlock];
    }];
}


#pragma mark - MNIUrlDownloaderDelegate

- (void)didReceiveData:(NSData *)data completion:(MNIURLDownloaderCompletionBlock)completionBlock {
    NSError *deserializingError;
    id object = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions
                                                  error:&deserializingError];
    if (deserializingError) {
        MILogError(@"error in NSJSONSerialization: %@ (%@)", deserializingError.localizedDescription, deserializingError.localizedFailureReason);
        //more error handling
    }
    
    NSArray *arrayOfSections = object[@"sections"];
    if (arrayOfSections.count > 0)
        [self processSectionDataWithSectionArray:arrayOfSections];
    else {
        // here we should handle article/articles donwloads when we
        // have a solid reponse structure from API team
        MILogError(@"unexpected lack of sections");
    }
    if (completionBlock) {
        completionBlock(data, nil, YES);
    }
}

- (void)didFailWithError:(NSError *)error completion:(MNIURLDownloaderCompletionBlock)completionBlock {
    //FIXME : should alert the user ?
    MILogError(@"error downloading : %@ (%@)",error.localizedDescription, error.localizedFailureReason);
    if (completionBlock) {
        completionBlock(nil, error, NO);
    }
}

#pragma mark - Process downloaded data

- (void)processSectionDataWithSectionArray:(NSArray *)sectionArray
{
    // debug output
    {
        NSMutableString *dbgMsg = [[NSMutableString alloc] init];
        for (NSDictionary *sectionDictionary in sectionArray) {
            NSString *sectionId = sectionDictionary[@"section_id"];
            [dbgMsg appendFormat:@"%@, ", sectionId];
        }
        MILogDebug(@"Processing datablock containing sections %@", dbgMsg);
    }
    
    NSManagedObjectContext *moc = [[MNIDataController sharedDataController] workerObjectContext];
//    if (self.fetchedResultsController) {
//        moc = self.fetchedResultsController.managedObjectContext;
//    } else {
//        moc = [[MNIDataController sharedDataController] workerObjectContext];
//    }
    for (NSDictionary *sectionDictionary in sectionArray) {
        NSString *sectionId = sectionDictionary[@"section_id"];
        NSFetchRequest *fetchRequest = [self fetchRequestForStoriesInSectionIds:@[ sectionId ] withMOC:moc];
        
        NSError *error = nil;
        NSArray *fetchedStories = [moc executeFetchRequest:fetchRequest error:&error];
        if (fetchedStories == nil || error != nil) {
            //error handling
        }
        
        [self deleteStoriesInArray:fetchedStories withMOC:moc];
        
        for (NSDictionary *sectionItem in sectionDictionary[@"items"]) {
            MNIStory *newStory = [self newStoryWithStoryDictionary:sectionItem withMOC:moc];
            newStory.sectionId = sectionId;
        }
    }
    
    [self saveContext:moc];
}

- (void)deleteStoriesInArray:(NSArray*)storyArray withMOC:(NSManagedObjectContext *)moc
{
    // FIXME: change this for a batch request later on
    for (NSManagedObject *storyObject in storyArray) {
        [moc deleteObject:storyObject];
    }
}

#pragma mark - helpers

- (MNIStory*)newStoryWithStoryDictionary:(NSDictionary*)storyDictionary withMOC:(NSManagedObjectContext *)moc
{
    MNIStory *newStory = [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:moc];
    newStory.storyId = storyDictionary[@"id"];
    newStory.fetchedDate = [NSDate date];
    newStory.storyContentTransformation = storyDictionary;
    
    return newStory;
}

- (void)saveContext:(NSManagedObjectContext *)moc
{
    [[MNIDataController sharedDataController] persistWorkerMOCChanges:moc synchronous:YES withCompletion:^(NSError *error) {
        if (error != nil) {
            MILogError(@"error downloading : %@ (%@)",error.localizedDescription, error.localizedFailureReason);
            //handle error
        }
    }];

}


@end
