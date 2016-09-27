//
//  testMNIStoryManager.m
//  phoenix-reader
//
//  Created by Yann Duran on 3/17/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNIStoryManager.h"
#import "MNIURLDownloader.h"
#import "MNIDataController.h"
#import <OCMock/OCMock.h>

@interface testMNIStoryManager : XCTestCase <MNIURLDownloaderDelegate>

@end

@implementation testMNIStoryManager

MNIStoryManager *manager;
MNIURLDownloader *downloader;

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    manager = [[MNIStoryManager alloc] init];
    downloader = [[MNIURLDownloader alloc] init];
    manager.downloader = downloader;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testMNIStoryManagerFetchedResultsControllerInstance {
    NSFetchedResultsController *frc = [manager fetchedResultsControllerForStoriesInSectionIds:[NSArray arrayWithObject:@"3402"] delegate:nil];
    XCTAssertNotNil(frc, @"not nil");
}

- (void)testMNIStoryManagerFetchedResultsController {
    NSString *sectoinId = @"333";

    NSManagedObjectContext *workerContext = [[MNIDataController sharedDataController] workerObjectContext];
    
    MNIStory *newStory = [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:workerContext];
    newStory.sectionId = sectoinId;
    newStory.storyId = @"333";
    newStory.fetchedDate = [NSDate date];

    [[MNIDataController sharedDataController] persistWorkerMOCChanges:workerContext synchronous:YES withCompletion:^(NSError *error) {
        XCTAssertNil(error, @"error found: %@",error);
    }];

    NSFetchedResultsController *frc = [manager fetchedResultsControllerForStoriesInSectionIds:[NSArray arrayWithObject:sectoinId] delegate:nil];
        
    XCTAssertFalse(frc.fetchedObjects.count == 0, @"Should have at least one object");
}

- (void)testMNIStoryManagerFetchedResultsControllerWithSections {
    
    NSManagedObjectContext *workerContext = [[MNIDataController sharedDataController] workerObjectContext];
    
    MNIStory *newStory1 = [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:workerContext];
    newStory1.sectionId = @"1";
    newStory1.storyId = @"333";
    newStory1.fetchedDate = [NSDate date];
    
    MNIStory *newStory2 = [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:workerContext];
    newStory2.sectionId = @"2";
    newStory2.storyId = @"333";
    newStory2.fetchedDate = [NSDate date];
    
    [[MNIDataController sharedDataController] persistWorkerMOCChanges:workerContext synchronous:YES withCompletion:^(NSError *error) {
        XCTAssertNil(error, @"error found: %@",error);
    }];
    
    NSFetchedResultsController *frc = [manager fetchedResultsControllerForStoriesInSectionIds:[NSArray arrayWithObjects:@"1", @"2", nil] delegate:nil];
    
    XCTAssertFalse(frc.fetchedObjects.count == 0, @"Should have at least one object");
    XCTAssertFalse(frc.sections.count == 0, @"Should have at least one section");
}


// make sure the download stars
- (void)testMNIStoryManagerDownloadRequestDidStart {
    
    id myObjectMock = OCMPartialMock(downloader);
    
    [manager downloadSectionWithSectionIds:@[@"3179"] completion:^(NSData *data, NSError *error, BOOL success) {
        
    }];
    
    OCMVerify([myObjectMock downloadDataFromUrl:[OCMArg any] withDelegate:[OCMArg any]]);
}


@end
