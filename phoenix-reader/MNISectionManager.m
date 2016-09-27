//
//  MNISectionHandler.m
//  phoenix-reader
//
//  Created by SANDEEP on 9/21/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNISectionManager.h"
#import "MNIDataController.h"
#import "MNIServerConfigManager.h"
#import "MILog.h"
#import "MNIStory.h"
#import <BlocksKit/BlocksKit.h>

@interface MNISectionManager ()

@property (strong, nonatomic) MNIURLDownloader* downloader;


@end

@implementation MNISectionManager


- (MNIURLDownloader *)downloader {
    if (_downloader == nil) {
        _downloader = [[MNIURLDownloader alloc] init];
    }
    return _downloader;
}

#pragma mark - Fetch Requests


- (NSFetchRequest *)fetchRequestForSectionsInSectionIds:(NSArray *)sections withStoryCheck:(BOOL)isStoryCheck withMOC:(NSManagedObjectContext *)moc {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[MNISection entityName] inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSArray *sectionIds = [sections bk_map:^id(MNIConfigSectionModel *obj) {
        return obj.section_id;
    }];
    NSArray *sectionNames = [sections bk_map:^id(MNIConfigSectionModel *obj) {
        return obj.name;
    }];
    NSArray *contentTypes = [sections bk_map:^id(MNIConfigSectionModel *obj) {
        return obj.contentType;
    }];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sectionID IN %@ && name IN %@ && contentType IN %@", sectionIds, sectionNames, contentTypes];
    NSMutableArray *predicateArray = [NSMutableArray arrayWithObject:predicate];
    if (isStoryCheck) {
        NSPredicate *storyCheckPredicate = [NSPredicate predicateWithFormat:@"stories.@count > 0"];
        [predicateArray addObject:storyCheckPredicate];
    }
    
    if ([sections count] == 1) {
        MNIConfigSectionModel *sectionConfig = [sections firstObject];
        if (sectionConfig.parentConfigSection) {
            NSPredicate *storyCheckPredicate = [NSPredicate predicateWithFormat:@"ANY sections.sectionID == %@",sectionConfig.parentConfigSection.section_id];
            [predicateArray addObject:storyCheckPredicate];
        }
    }
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
    [fetchRequest setPredicate:compoundPredicate];
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObjects:descriptor, nil];
    [fetchRequest setSortDescriptors:descriptors];
    [fetchRequest setReturnsDistinctResults:YES];
    
    return fetchRequest;
}

- (NSFetchRequest *)fetchRequestForSectionsInSectionIds:(NSArray *)sectionIds withMOC:(NSManagedObjectContext *)moc {
    return [self fetchRequestForSectionsInSectionIds:sectionIds withStoryCheck:NO withMOC:moc];
}

- (void)getUpdatedSectionsforSectionID:(NSArray *)sections withComplitionHandeler:(void(^)(NSArray *fetchedSections, NSError *error, BOOL isDownloading))complitionHandler {
    
    NSManagedObjectContext *moc = [[MNIDataController sharedDataController] workerObjectContext];
    NSFetchRequest *fetchRequest = [self fetchRequestForSectionsInSectionIds:sections withStoryCheck:YES withMOC:moc];
    [moc performBlock:^{
        NSError *error = nil;
        NSArray *fetchResult = [moc executeFetchRequest:fetchRequest error:&error];
        
        BOOL isDownloadStories = NO;
        
        if ([fetchResult count] == 0) {
            isDownloadStories = YES;
        } else {
            MNIServerConfigModel *configModel = [[MNIServerConfigManager sharedManager] serverConfigModel];
            NSInteger storyPerSection = ([sections count] > 1) ? configModel.sections_info.stories_shown_per_section : configModel.sections_info.multisection.stories_shown;
            isDownloadStories = ([sections count] == 1 && [(MNISection*)[fetchResult firstObject] stories].count == storyPerSection);
        }
        if (isDownloadStories) {
            [self downloadSectionWithSections:sections completion:^(id responseResult, NSError *error, BOOL success) {
                complitionHandler(responseResult, error, NO);
            }];
        }
        complitionHandler(fetchResult, error, isDownloadStories);
    }];
    
}



#pragma mark - Download

- (void)downloadSectionWithSections:(NSArray *)sections completion:(MNIURLDownloaderCompletionBlock)completionBlock {
    
    MNIServerConfigModel *configModel = [[MNIServerConfigManager sharedManager] serverConfigModel];
    NSString *baseUrl = configModel.apiInfo.baseUrl;
    MNIConfigSectionsInfoModel *sectionsInfo = configModel.sections_info;
    
    NSMutableString *sectioEndPointUrl = [NSMutableString stringWithFormat:@"%@v1/sections/",baseUrl];
    if (sections.count == 1) {
        MNIConfigSectionModel *sectionModel = [sections firstObject];
        NSString *storyPerSectionLimit = [NSString stringWithFormat:@"%ld",(long)configModel.sections_info.stories_shown_per_section];
        if (sectionModel.contentType && ![sectionModel.contentType isEqualToString:@"content"]) {
            [sectioEndPointUrl appendString:[NSString stringWithFormat:@"%@/contentType/%@/limit/%@",sectionModel.section_id,sectionModel.contentType,storyPerSectionLimit]];
        } else {
            [sectioEndPointUrl appendString:[NSString stringWithFormat:@"%@/limit/%@",sectionModel.section_id,storyPerSectionLimit]];
        }
    } else {
        
        for (MNIConfigSectionModel *sectionModel in sections) {
            MNIConfigMultiSectionsModel *multisection = sectionsInfo.multisection;
            NSInteger storyPerSection = [sectionModel isTopSection] ? multisection.top_stories_shown : multisection.stories_shown;
            if (sectionModel.contentType && ![sectionModel.contentType isEqualToString:@"content"]) {
                [sectioEndPointUrl appendString:[NSString stringWithFormat:@"sectionId=%@,limit=%ld,contentType=%@;",sectionModel.section_id,(long)storyPerSection,sectionModel.contentType]];
            } else {
                [sectioEndPointUrl appendString:[NSString stringWithFormat:@"sectionId=%@,limit=%ld;",sectionModel.section_id,(long)storyPerSection]];
            }
        }
    }
    
    NSURL *urlToDownload = [NSURL URLWithString:sectioEndPointUrl];
    [self.downloader downloadDataFromUrl:urlToDownload withSuccessBlock:^(NSData *data) {
        [self didReceiveData:data withRequestSections:sections completion:completionBlock];
    } andFailureBlock:^(NSError *error) {
        [self didFailWithError:error completion:completionBlock];
    }];
}


#pragma mark - MNIUrlDownloaderDelegate

- (void)didReceiveData:(NSData *)data withRequestSections:(NSArray *)sections completion:(MNIURLDownloaderCompletionBlock)completionBlock {
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
        [self processSectionArray:arrayOfSections withRequestSections:sections completion:completionBlock];
    else {
        if (completionBlock) {
            completionBlock(nil, deserializingError, NO);
        }
        // here we should handle article/articles donwloads when we
        // have a solid reponse structure from API team
        MILogError(@"unexpected lack of sections");
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

- (void)processSectionArray:(NSArray *)sectionArray withRequestSections:(NSArray *)sections completion:(MNIURLDownloaderCompletionBlock)completionBlock
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
    
    NSFetchRequest *fetchRequest = [self fetchRequestForSectionsInSectionIds:sections withMOC:moc];
    
    [moc performBlock:^{
        NSError *error = nil;
        NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:&error];
        NSMutableArray *sectionWithStory = [[NSMutableArray alloc] init];
        for (MNISection *section in fetchResults) {
            for (MNIStory *oldStory in section.stories) {
                [moc deleteObject:oldStory];
            }
            MNIConfigSectionModel *sectionConfig = [sections bk_match:^BOOL(MNIConfigSectionModel *obj) {
                return [obj.section_id isEqualToString:section.sectionID] && [obj.name isEqualToString:section.name];
            }];
            NSInteger index = [sections indexOfObject:sectionConfig];
            NSDictionary *sectionDictionary = sectionArray[index];
            
            NSMutableSet *storiesSet = [[NSMutableSet alloc] init];
            for (NSDictionary *sectionItem in sectionDictionary[@"items"]) {
                MNIStory *newStory = [self newStoryWithStoryDictionary:sectionItem withMOC:moc];
                newStory.sectionId = section.sectionID;
                [storiesSet addObject:newStory];
            }
            [section addStories:storiesSet];
            if ([section.stories count] > 0 || ([sectionArray count] == 1)) {
                [sectionWithStory addObject:section];
            }
        }
        [self saveContext:moc];
        
        if (completionBlock) {
            completionBlock(sectionWithStory, error, YES);
        }
    }];
    
    
    
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
