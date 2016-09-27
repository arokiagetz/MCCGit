//
//  testMNIStoryCellViewModel.m
//  phoenix-reader
//
//  Created by Sarat Chandran on 4/8/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNIStoryCellViewModel.h"

@interface testMNIStoryCellViewModel : XCTestCase

@end

@implementation testMNIStoryCellViewModel

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testStoryCellViewModelDisplayDate {
    MNIStoryCellViewModel* storyCellViewModel = [[MNIStoryCellViewModel alloc] init];
    storyCellViewModel.headline = @"headline";
    storyCellViewModel.detail = @"detail";
    storyCellViewModel.image = @"image";
    storyCellViewModel.storyCellType = MNIStandardStoryCell;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *referenceDate = [dateFormatter dateFromString: @"2016-04-08 12:23:00"];

    NSDate *date0 = [dateFormatter dateFromString: @"2016-04-08 12:00:00"];
    NSDate *date01 = [dateFormatter dateFromString: @"2016-04-08 12:22:00"];
    NSDate *date11 = [dateFormatter dateFromString: @"2016-04-08 11:20:00"];
    NSDate *date1 = [dateFormatter dateFromString: @"2016-04-08 05:00:00"];
    NSDate *date2 = [dateFormatter dateFromString: @"2016-04-07 23:59:59"];
    NSDate *date3 = [dateFormatter dateFromString: @"2016-04-06 23:59:59"];
    NSDate *date4 = [dateFormatter dateFromString: @"2016-04-05 23:59:59"];
    NSDate *date5 = [dateFormatter dateFromString: @"2016-04-04 23:59:59"];
    NSDate *date6 = [dateFormatter dateFromString: @"2016-04-03 23:59:59"];
    NSDate *date7 = [dateFormatter dateFromString: @"2016-04-02 23:59:59"];
    NSDate *date8 = [dateFormatter dateFromString: @"2016-03-04 23:59:59"];
    [storyCellViewModel setPublishedDate:date01 referenceDate:referenceDate];
    XCTAssertTrue([storyCellViewModel.publishedDateDisplay isEqualToString:@"1 minute ago"] == YES, @"minute ago");
    [storyCellViewModel setPublishedDate:date0 referenceDate:referenceDate];
    XCTAssertTrue([storyCellViewModel.publishedDateDisplay isEqualToString:@"23 minutes ago"] == YES, @"minutes ago");
    [storyCellViewModel setPublishedDate:date11 referenceDate:referenceDate];
    XCTAssertTrue([storyCellViewModel.publishedDateDisplay isEqualToString:@"1 hour ago"] == YES, @"hour ago");
    [storyCellViewModel setPublishedDate:date1 referenceDate:referenceDate];
    XCTAssertTrue([storyCellViewModel.publishedDateDisplay isEqualToString:@"7 hours ago"] == YES, @"hours ago");
    [storyCellViewModel setPublishedDate:date2 referenceDate:referenceDate];
    XCTAssertTrue([storyCellViewModel.publishedDateDisplay isEqualToString:@"Yesterday"] == YES, @"Yesterday");
    [storyCellViewModel setPublishedDate:date3 referenceDate:referenceDate];
    XCTAssertTrue([storyCellViewModel.publishedDateDisplay isEqualToString:@"Wednesday"] == YES, @"Wednesday");
    [storyCellViewModel setPublishedDate:date4 referenceDate:referenceDate];
    XCTAssertTrue([storyCellViewModel.publishedDateDisplay isEqualToString:@"Tuesday"] == YES, @"Tuesday");
    [storyCellViewModel setPublishedDate:date5 referenceDate:referenceDate];
    XCTAssertTrue([storyCellViewModel.publishedDateDisplay isEqualToString:@"Monday"] == YES, @"Monday");
    [storyCellViewModel setPublishedDate:date6 referenceDate:referenceDate];
    XCTAssertTrue([storyCellViewModel.publishedDateDisplay isEqualToString:@"Sunday"] == YES, @"Sunday");
    [storyCellViewModel setPublishedDate:date7 referenceDate:referenceDate];
    XCTAssertTrue([storyCellViewModel.publishedDateDisplay isEqualToString:@"04/02/2016"] == YES, @"edge case");
    [storyCellViewModel setPublishedDate:date8 referenceDate:referenceDate];
    XCTAssertTrue([storyCellViewModel.publishedDateDisplay isEqualToString:@"03/04/2016"] == YES, @"03/04/2016");

    referenceDate = [dateFormatter dateFromString: @"2016-01-01 12:23:00"];
    date0 = [dateFormatter dateFromString: @"2015-12-31 12:00:00"];
    date1 = [dateFormatter dateFromString: @"2015-12-30 05:00:00"];
    date2 = [dateFormatter dateFromString: @"2015-12-29 23:59:59"];
    date3 = [dateFormatter dateFromString: @"2015-12-28 23:59:59"];
    date4 = [dateFormatter dateFromString: @"2015-12-27 23:59:59"];
    date5 = [dateFormatter dateFromString: @"2015-12-26 23:59:59"];
    date6 = [dateFormatter dateFromString: @"2015-12-25 23:59:59"];
    date7 = [dateFormatter dateFromString: @"2016-12-24 23:59:59"];
    [storyCellViewModel setPublishedDate:date0 referenceDate:referenceDate];
    XCTAssertTrue([storyCellViewModel.publishedDateDisplay isEqualToString:@"Yesterday"] == YES, @"Yesterday");
    [storyCellViewModel setPublishedDate:date1 referenceDate:referenceDate];
    XCTAssertTrue([storyCellViewModel.publishedDateDisplay isEqualToString:@"Wednesday"] == YES, @"Wednesday");
    [storyCellViewModel setPublishedDate:date2 referenceDate:referenceDate];
    XCTAssertTrue([storyCellViewModel.publishedDateDisplay isEqualToString:@"Tuesday"] == YES, @"Tuesday");
    [storyCellViewModel setPublishedDate:date3 referenceDate:referenceDate];
    XCTAssertTrue([storyCellViewModel.publishedDateDisplay isEqualToString:@"Monday"] == YES, @"Monday");
    [storyCellViewModel setPublishedDate:date4 referenceDate:referenceDate];
    XCTAssertTrue([storyCellViewModel.publishedDateDisplay isEqualToString:@"Sunday"] == YES, @"Sunday");
    [storyCellViewModel setPublishedDate:date7 referenceDate:referenceDate];
    XCTAssertTrue([storyCellViewModel.publishedDateDisplay isEqualToString:@"12/24/2016"] == YES, @"edge case");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
