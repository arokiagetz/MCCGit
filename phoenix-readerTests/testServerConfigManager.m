//
//  testServerConfigManager.m
//  phoenix-reader
//
//  Created by Scott Ferwerda on 3/17/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MNIServerConfigManager+Testable.h"

#define ASYNC_TEST_TIMEOUT 10

@interface testServerConfigManager : XCTestCase
{
    MNIDataController *testDataController;
    NSManagedObjectContext *testMOC;
}
@end

@implementation testServerConfigManager

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    testDataController = [[MNIDataController alloc] initWithDatabaseName:@"phoenix_reader_unit_tests.sqlite"];
    testMOC = [testDataController mainManagedObjectContext];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [testDataController persistMOCChanges:^(NSError *erorr) {
        //
    }];
}

- (void)paveDatastore {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[MNIServerConfig entityName]];
    fetchRequest.includesPropertyValues = NO;
    NSError *error = nil;
    NSArray *fetchResults = [testMOC executeFetchRequest:fetchRequest error:&error];
    XCTAssertNil(error, @"error in fetch");
    
    for (MNIServerConfig *aServerConfigObject in fetchResults) {
        [testMOC deleteObject:aServerConfigObject];
    }

    [testMOC save:&error];
    XCTAssertNil(error, @"error in save");
}

- (void)fakeGoodDataFromUrl:(NSURL *)url withSuccessBlock:(void (^)(NSData *data))success andFailureBlock:(void (^)(NSError *error))failure
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filepath = [bundle pathForResource:@"testing-server-config" ofType:@"json"];
    NSData *contentOfSampleFile = [NSData dataWithContentsOfFile:filepath];
    success(contentOfSampleFile);
}

- (void)fakeBadDataFromUrl:(NSURL *)url withSuccessBlock:(void (^)(NSData *data))success andFailureBlock:(void (^)(NSError *error))failure
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filepath = [bundle pathForResource:@"bad-testing-server-config" ofType:@"json"];
    NSData *contentOfSampleFile = [NSData dataWithContentsOfFile:filepath];
    success(contentOfSampleFile);
}

- (void)fakeServerErrorFromUrl:(NSURL *)url withSuccessBlock:(void (^)(NSData *data))success andFailureBlock:(void (^)(NSError *error))failure
{
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"A faked-up error occurred." };
    NSError *fakeError = [NSError errorWithDomain:@"MNIHTTPStatusError"
                                         code:500
                                     userInfo:userInfo];
    failure(fakeError);
}

- (MNIServerConfigManager *)constructMockedServerConfigManagerWithDownloader:(id)downloader
{
    NSString *urlString = @"http://static.mcclatchyinteractive.com/mobile_app_configs/test/ios/generic_ios_testing_server_config.json";
    MNIServerConfigManager *scm = [[MNIServerConfigManager alloc] initWithURL:[NSURL URLWithString:urlString] andDataController:testDataController];
    XCTAssertNotNil(scm, @"failed to initialize the config manager");
    
    scm.downloader = downloader;
    
    XCTAssertEqual(urlString, scm.serverConfigUrl.absoluteString, @"configured url mismatch");
    XCTAssertNil(scm.serverConfigModel, @"failed to initialize the server config model to nil");
    XCTAssertNil(scm.lastUpdatedDate, @"failed to initialize the last updated date to nil");
    
    return scm;
}

// verify basic object initialization
- (void)test010Construct {

    [self paveDatastore];

    NSString *urlString = @"test";
    MNIServerConfigManager *scm = [[MNIServerConfigManager alloc] initWithURL:[NSURL URLWithString:urlString] andDataController:testDataController];

    XCTAssertNotNil(scm, @"failed to initialize the config manager");
    XCTAssertEqual(urlString, scm.serverConfigUrl.absoluteString, @"configured url mismatch");
    XCTAssertNil(scm.serverConfigModel, @"failed to initialize the server config model to nil");
    XCTAssertNil(scm.lastUpdatedDate, @"failed to initialize the last updated date to nil");
}

// verify fetch logic using mocked data
- (void)test050GoodFetchFromMock {

    XCTestExpectation *expectation = [self expectationWithDescription:@"test_mock_fetch"];

    [self paveDatastore];

    // set up mock for MNIUrlDownloader
    id downloaderMock = OCMClassMock([MNIURLDownloader class]);
    OCMStub([downloaderMock downloadDataFromUrl:[OCMArg any] withSuccessBlock:[OCMArg any] andFailureBlock:[OCMArg any]]).andCall(self, @selector(fakeGoodDataFromUrl:withSuccessBlock:andFailureBlock:));
    
    // construct a manager with the mocked downloader
    MNIServerConfigManager *scm = [self constructMockedServerConfigManagerWithDownloader:downloaderMock];
    
    // run the mocked fetch
    [scm fetchServerConfigWithSuccessBlock:^(MNIServerConfigModel *aServerConfigModel, NSDate *lastUpdatedDate) {
        XCTAssertNotNil(aServerConfigModel, @"fetched server config model is nil");
        [expectation fulfill];
    } andFailureBlock:^(NSError *error) {
        XCTFail(@"errored out");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:ASYNC_TEST_TIMEOUT handler:^(NSError *error) {
        [(OCMockObject *)(scm.downloader) stopMocking];
        XCTAssertNil(error, @"error in fetch");
    }];
    
}

- (void)test060BadFetchFromMock {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"test_mock_fetch"];
    
    [self paveDatastore];
    
    // set up mock for MNIUrlDownloader
    id downloaderMock = OCMClassMock([MNIURLDownloader class]);
    OCMStub([downloaderMock downloadDataFromUrl:[OCMArg any] withSuccessBlock:[OCMArg any] andFailureBlock:[OCMArg any]]).andCall(self, @selector(fakeBadDataFromUrl:withSuccessBlock:andFailureBlock:));
    
    // construct a manager with the mocked downloader
    MNIServerConfigManager *scm = [self constructMockedServerConfigManagerWithDownloader:downloaderMock];
    
    [scm fetchServerConfigWithSuccessBlock:^(MNIServerConfigModel *aServerConfigModel, NSDate *lastUpdatedDate) {
        XCTAssertNotNil(aServerConfigModel, @"fetched server config model is nil");
        [expectation fulfill];
    } andFailureBlock:^(NSError *error) {
        XCTFail(@"errored out");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        [downloaderMock stopMocking];
        XCTAssertNil(error, @"error in fetch");
    }];
    
}

- (void)test070ErrorFetchFromMock {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"test_mock_fetch"];
    
    [self paveDatastore];
    
    // set up mock for MNIUrlDownloader
    id downloaderMock = OCMClassMock([MNIURLDownloader class]);
    OCMStub([downloaderMock downloadDataFromUrl:[OCMArg any] withSuccessBlock:[OCMArg any] andFailureBlock:[OCMArg any]]).andCall(self, @selector(fakeServerErrorFromUrl:withSuccessBlock:andFailureBlock:));
    
    // construct a manager with the mocked downloader
    MNIServerConfigManager *scm = [self constructMockedServerConfigManagerWithDownloader:downloaderMock];
    
    [scm fetchServerConfigWithSuccessBlock:^(MNIServerConfigModel *aServerConfigModel, NSDate *lastUpdatedDate) {
        XCTFail(@"fetch returned success even though server mocked to return an error status");
        [expectation fulfill];
    } andFailureBlock:^(NSError *error) {
        XCTAssertEqual(error.code, 500, @"fetch failed to return the expected 500 error");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        [downloaderMock stopMocking];
        XCTAssertNil(error, @"error in fetch");
    }];
    
}

- (void)test110IsNotStale {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"test_real_fetch"];
    
    [self paveDatastore];

    // fetch real data
    NSString *urlString = @"http://static.mcclatchyinteractive.com/mobile_app_configs/test/ios/generic_ios_testing_server_config.json";
    MNIServerConfigManager *scm = [[MNIServerConfigManager alloc] initWithURL:[NSURL URLWithString:urlString] andDataController:testDataController];
    XCTAssertNotNil(scm, @"failed to initialize the config manager");
    
    XCTAssertEqual(urlString, scm.serverConfigUrl.absoluteString, @"configured url mismatch");
    XCTAssertNil(scm.serverConfigModel, @"failed to initialize the server config model to nil");
    XCTAssertNil(scm.lastUpdatedDate, @"failed to initialize the last updated date to nil");
    
    [scm fetchServerConfigWithSuccessBlock:^(MNIServerConfigModel *aServerConfigModel, NSDate *lastUpdatedDate) {
        XCTAssertNotNil(aServerConfigModel, @"fetched server config model is nil");
        // check staleness
        XCTAssertFalse([scm serverConfigIsStale], "server config unexpectedly marked stale");
        [expectation fulfill];
    } andFailureBlock:^(NSError *error) {
        XCTFail(@"errored out");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:ASYNC_TEST_TIMEOUT handler:^(NSError *error) {
        XCTAssertNil(error, @"error in fetch");
    }];
    
}

@end
