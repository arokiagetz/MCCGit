//
//  testMNIErrorCentral.m
//  phoenix-reader
//
//  Created by Yann Duran on 3/29/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNIErrorCentral.h"

@interface testMNIErrorCentral : XCTestCase
@end

@implementation testMNIErrorCentral

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self clearAllAlertContexts];
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

- (void)clearAllAlertContexts
{
    MNIErrorCentral *central = [MNIErrorCentral sharedErrorCentral];
    [central.outstandingAlertContexts removeAllObjects];
    [central.queuedAlertContexts removeAllObjects];
}

- (void)testErrorCentralInstance
{
    MNIErrorCentral *central = [MNIErrorCentral sharedErrorCentral];
    XCTAssertNotNil(central, @"instance not created.");
}

- (void)testErrorCentralSingleton
{
    MNIErrorCentral *central1 = [MNIErrorCentral sharedErrorCentral];
    MNIErrorCentral *central2 = [MNIErrorCentral sharedErrorCentral];
    XCTAssertEqual(central1, central2, @"should be the same");
}

- (void)testOutstandingAlertContexts
{
    MNIErrorCentral *central = [MNIErrorCentral sharedErrorCentral];

    NSError *error = [MNIErrorCentral customErrorWithDomain:@"domain" code:1 andUserInfo:nil];
    [central presentError:error withOptionsAndCallbacks:
     @"Ok",^void{
         NSLog(@"ok");
     },
     @"retry",^void{
         NSLog(@"try");
     }, nil];
   
    XCTAssertTrue(central.outstandingAlertContexts.count == 1, @"should have one object");
}

- (void)testOutstandingAlertContextsAndQueued
{
    MNIErrorCentral *central = [MNIErrorCentral sharedErrorCentral];

    NSError *error = [MNIErrorCentral customErrorWithDomain:@"domain" code:1 andUserInfo:nil];
    
    [central presentError:error withOptionsAndCallbacks:
     @"Ok",^void{
         NSLog(@"ok");
     },
     @"retry",^void{
         NSLog(@"try");
     }, nil];
    
    [central presentError:error withOptionsAndCallbacks:
     @"Ok",^void{
         NSLog(@"ok");
     },
     @"retry",^void{
         NSLog(@"try");
     }, nil];
    
    XCTAssertTrue(central.outstandingAlertContexts.count == 2, @"should have two objects");
    XCTAssertTrue(central.queuedAlertContexts.count == 1 , @"should have one object");
}


- (void)testErrorCentralActionsAdded
{
    MNIErrorCentral *central = [MNIErrorCentral sharedErrorCentral];
    
    NSError *error = [MNIErrorCentral customErrorWithDomain:@"domain" code:1 andUserInfo:nil];
    
    [central presentError:error withOptionsAndCallbacks:
     @"Ok",^void{
         NSLog(@"ok");
     },
     @"retry",^void{
         NSLog(@"try");
     }, nil];
    
    MNIErrorCentralAlertContext *context = central.outstandingAlertContexts.firstObject;
    UIAlertController *alert = context.alert;
    XCTAssertTrue(alert.actions.count == 2, @"should have two objects");
}

- (void)testErrorCentralPresentAlert
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = storyboard.instantiateInitialViewController;
    [UIApplication sharedApplication].keyWindow.rootViewController = vc;

    MNIErrorCentral *central = [MNIErrorCentral sharedErrorCentral];
    
    NSError *error = [MNIErrorCentral customErrorWithDomain:@"domain" code:1 andUserInfo:nil];
    
    [central presentError:error withOptionsAndCallbacks:
     @"Ok",^void{
         NSLog(@"ok");
     },
     @"retry",^void{
         NSLog(@"try");
     }, nil];
    
    XCTAssertTrue([vc.presentedViewController isKindOfClass:[UIAlertController class]],@"the presented controller should be alertController");
}



@end
