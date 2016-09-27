//
//  testMNIStoryModel.m
//  phoenix-reader
//
//  Created by Yann Duran on 3/15/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNIStoryModel.h"

@interface testMNIStoryModel : XCTestCase

@end

@implementation testMNIStoryModel

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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


//testing the code used in the size transformation
- (void)testSizeTransformation {
    
    NSDictionary *dictionary = @{@"width" : @"640", @"height" : @"480"};
    
    NSError *adapterError;
    MNIStoryModel *model = [MTLJSONAdapter modelOfClass:[MNIStoryModel class] fromJSONDictionary:dictionary error:&adapterError];
    XCTAssertNil(adapterError,@"Adapter error: %@",adapterError);
    XCTAssertTrue(model.size.width == 640, @"wrong width");
    XCTAssertTrue(model.size.height == 480, @"wrong height");
}

- (void)testStoryMapping
{
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"testing-story-mapping" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSError *adapterError;
    MNIStoryModel *model = [MTLJSONAdapter modelOfClass:[MNIStoryModel class] fromJSONDictionary:jsonObject error:&adapterError];
    XCTAssertNil(adapterError,@"Adapter error: %@",adapterError);
    XCTAssertNotNil(model,@"Not nil");
}

@end
