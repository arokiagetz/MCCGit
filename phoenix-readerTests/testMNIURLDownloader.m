//
//  testMNIURLDownloader.m
//  phoenix-reader
//
//  Created by Yann Duran on 3/8/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNIURLDownloader.h"
#import <OCMock/OCMock.h>


@interface testMNIURLDownloader : XCTestCase

@end

@implementation testMNIURLDownloader

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

- (void)testInstance
{
    MNIURLDownloader *downloader = [[MNIURLDownloader alloc] initWithSession:nil];
    XCTAssertNotNil(downloader, @"instance not created.");
}

- (void)testInstanceSessionParam
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];
    
    MNIURLDownloader *downloader = [[MNIURLDownloader alloc] initWithSession:session];
    XCTAssertEqualObjects(session, downloader.session, @"instances are not the same.");
}

- (void)testSession
{
    MNIURLDownloader *downloader = [[MNIURLDownloader alloc] initWithSession:nil];
    NSURLSession *session = [downloader session];
    XCTAssertNotNil(session, @"property not set.");

}

- (void)testSessionWhenInit
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session1 = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];
    
    MNIURLDownloader *downloader = [[MNIURLDownloader alloc] initWithSession:session1];
    NSURLSession *session2 = [downloader session];
    XCTAssertNotNil(session2, @"property not set.");
}

- (void)testSessionWhenInitAreSame
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session1 = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];
    
    MNIURLDownloader *downloader = [[MNIURLDownloader alloc] initWithSession:session1];
    NSURLSession *session2 = [downloader session];
    XCTAssertEqualObjects(session1, session2, @"instances are not the same.");
}

- (void)testDownloadWithBlockUsingNetworkFail // client failure
{
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"request"];
    MNIURLDownloader *downloader = [[MNIURLDownloader alloc] init];
    [downloader downloadDataFromUrl:[NSURL URLWithString:@"/ios"] withSuccessBlock:^(NSData *data) {
        // do nothing
    } andFailureBlock:^(NSError *error) {
        [completionExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testDownloadWithBlockUsingNetworkSuccess
{
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"request"];
    MNIURLDownloader *downloader = [[MNIURLDownloader alloc] init];
    [downloader downloadDataFromUrl:[NSURL URLWithString:@"http://www.google.com"] withSuccessBlock:^(NSData *data) {
        [completionExpectation fulfill];
    } andFailureBlock:^(NSError *error) {
        // do nothing
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testCancel
{
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"request"];
    MNIURLDownloader *downloader = [[MNIURLDownloader alloc] init];
    [downloader downloadDataFromUrl:[NSURL URLWithString:@"http://www.google.com"] withSuccessBlock:^(NSData *data) {
        // do nothing
    } andFailureBlock:^(NSError *error) {
        [completionExpectation fulfill];
    }];
    
    [downloader cancel];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
}

//helpers

- (id)sessionMockForResponse:(NSDictionary*)response {
    id sessionMock = OCMClassMock([NSURLSession class]);
    OCMStub([sessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation){
        // Get the block from the call.
        void (^__unsafe_unretained completionBlock)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error);
        [invocation getArgument:&completionBlock atIndex:3];
        // Call the block with response, setting error as nil, will expand later on this mock
        completionBlock(response[@"data"], response[@"response"], nil);
    });
    return sessionMock;
}

// for now I only care about statusCode, will expand on this method later
- (NSDictionary*)customResponseWithHttpStatusCode:(NSInteger)code
{
    NSDictionary *serverResponse = @{
                                     @"response" : [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"SOMEURL"] statusCode:code HTTPVersion:nil headerFields:@{}],
                                     @"data" : [@"SOMEDATA" dataUsingEncoding:NSUTF8StringEncoding]
                                     };
    return serverResponse;
}

//
- (void)testDownloadWithBlockUsingMockSuccessWithHttp200
{
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"request"];

    NSDictionary *serverResponse = [self customResponseWithHttpStatusCode:200];
    id sessionMock = [self sessionMockForResponse:serverResponse];
    
    MNIURLDownloader *downloader = [[MNIURLDownloader alloc] initWithSession:sessionMock];
    [downloader downloadDataFromUrl:[NSURL URLWithString:@"SOMEURL"] withSuccessBlock:^(NSData *data) {
        [completionExpectation fulfill];
    } andFailureBlock:^(NSError *error) {
        //do nothing
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
}

- (void)testDownloadWithBlockUsingMockFailWithHttp300
{
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"request"];
    
    NSDictionary *serverResponse = [self customResponseWithHttpStatusCode:300];
    id sessionMock = [self sessionMockForResponse:serverResponse];
    
    MNIURLDownloader *downloader = [[MNIURLDownloader alloc] initWithSession:sessionMock];
    [downloader downloadDataFromUrl:[NSURL URLWithString:@"SOMEURL"] withSuccessBlock:^(NSData *data) {
        [completionExpectation fulfill];
    } andFailureBlock:^(NSError *error) {
        //do nothing
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testDownloadWithBlockUsingMockFailWithHttp404
{
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"request"];
    
    NSDictionary *serverResponse = [self customResponseWithHttpStatusCode:404];
    id sessionMock = [self sessionMockForResponse:serverResponse];
    
    MNIURLDownloader *downloader = [[MNIURLDownloader alloc] initWithSession:sessionMock];
    [downloader downloadDataFromUrl:[NSURL URLWithString:@"SOMEURL"] withSuccessBlock:^(NSData *data) {
        //do nothing
    } andFailureBlock:^(NSError *error) {
        [completionExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
}

- (void)testDownloadWithBlockUsingMockFailWithHttp500
{
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"request"];
    
    NSDictionary *serverResponse = [self customResponseWithHttpStatusCode:500];
    id sessionMock = [self sessionMockForResponse:serverResponse];
    
    MNIURLDownloader *downloader = [[MNIURLDownloader alloc] initWithSession:sessionMock];
    [downloader downloadDataFromUrl:[NSURL URLWithString:@"SOMEURL"] withSuccessBlock:^(NSData *data) {
        //do nothing
    } andFailureBlock:^(NSError *error) {
        [completionExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
}

// validate delegate callbacks
BOOL _callbackInvokedSuccess;
BOOL _callbackInvokedFail;

- (void)testDownloadWithDelegateUsingMockSuccessWithHttp200
{
    _callbackInvokedSuccess = NO;
    _callbackInvokedFail = NO;
    
    NSDictionary *serverResponse = [self customResponseWithHttpStatusCode:200];
    id sessionMock = [self sessionMockForResponse:serverResponse];
    
    MNIURLDownloader *downloader = [[MNIURLDownloader alloc] initWithSession:sessionMock];
    [downloader downloadDataFromUrl:[NSURL URLWithString:@"SOMEURL"] withDelegate:self];
    
    XCTAssertTrue(_callbackInvokedSuccess,"delegate call");
}

- (void)testDownloadWithDelegateUsingMockFailWithHttp404
{
    _callbackInvokedSuccess = NO;
    _callbackInvokedFail = NO;
    NSDictionary *serverResponse = [self customResponseWithHttpStatusCode:404];
    id sessionMock = [self sessionMockForResponse:serverResponse];
    
    MNIURLDownloader *downloader = [[MNIURLDownloader alloc] initWithSession:sessionMock];
    [downloader downloadDataFromUrl:[NSURL URLWithString:@"SOMEURL"] withDelegate:self];
    
    XCTAssertTrue(_callbackInvokedFail,"delegate call");
}

- (void)didReceiveData:(NSData *)data
{
    NSLog(@"%@",data);
    _callbackInvokedSuccess = YES;
}

- (void)didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
    _callbackInvokedFail = YES;
}



@end
