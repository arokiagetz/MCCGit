//
//  testMNISectionModel.m
//  phoenix-reader
//
//  Created by Yann Duran on 3/15/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreData/CoreData.h>
#import "MNIStory.h"
#import "MNIDataController.h"

@interface testMNIStories : XCTestCase



@end

@implementation testMNIStories

NSManagedObjectContext *managedObjectContext;


- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    managedObjectContext = [[MNIDataController sharedDataController] workerObjectContext];
}

- (void)tearDown {
    [managedObjectContext rollback];
    managedObjectContext = nil;
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

- (void)testStoryIsInitialised {
    
    MNIStory *story = (MNISection*)[NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:managedObjectContext];
    XCTAssertNotNil(story, @"should have a story");

}

- (void)testStoryMantleTransformation {
    MNIStory *story = (MNIStory*)[NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:managedObjectContext];
    story.storyContentTransformation = @{@"id" : @"123", @"title":@"Some Title"};
    XCTAssertNotNil(story.modelObjectForStoryContent.id, @"should not be nil");
    XCTAssertNotNil(story.modelObjectForStoryContent.title, @"should not be nil");
}

- (void)testStoryMantleTransformationFail {
    MNIStory *story = (MNIStory*)[NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:managedObjectContext];
    XCTAssertNil(story.modelObjectForStoryContent, @"should not be nil");
}

@end
