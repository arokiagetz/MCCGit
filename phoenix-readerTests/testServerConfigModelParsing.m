//
//  testServerConfigModelParsing.m
//  
//
//  Created by Sarat Chandran on 3/22/16.
//
//

#import <XCTest/XCTest.h>
#import <Mantle/Mantle.h>
#import "MNIServerConfigModels.h"

@interface testServerConfigModelParsing : XCTestCase

@end

@implementation testServerConfigModelParsing

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testServerConfigParse {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    NSError *error;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *serverConfigURL = [bundle URLForResource:@"phoenixDevConfig" withExtension:@"json"];
    id object = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:serverConfigURL]
                                                options:kNilOptions
                                                  error:&error];
    XCTAssertNil(error, @"read json from config");
    
    MNIServerConfigModel* config = [MTLJSONAdapter modelOfClass:[MNIServerConfigModel class] fromJSONDictionary:object error:&error];
    XCTAssertNil(error, @"parse Mantle object");
    NSDictionary* multisection = [MTLJSONAdapter JSONDictionaryFromModel:config.sections_info.multisection error:&error];
    XCTAssertNil(error, @"read dictionary from config multisection mantle object");
    XCTAssertTrue(([multisection isEqualToDictionary:@{
                    @"top_stories_shown": @1,
                    @"top_story_section_id": @"3401",
                    @"sections_shown": @5,
                    @"stories_shown": @5
                    }]) == YES, @"multisection info");
    NSDictionary* sections_info = [MTLJSONAdapter JSONDictionaryFromModel:config.sections_info error:&error];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    XCTAssertTrue(([sections_info[@"stories_shown_per_section"] integerValue] == 20) == YES, @"section info");
    XCTAssertTrue(([[formatter numberFromString:sections_info[@"sections"][1][@"section_id"]] isEqualToNumber:@3403]) == YES, @"section info");
    XCTAssertTrue(([[formatter numberFromString:sections_info[@"sections"][2][@"section_id"]] isEqualToNumber:@3404]) == YES, @"section info");
    XCTAssertTrue(([[formatter numberFromString:sections_info[@"sections"][3][@"section_id"]] isEqualToNumber:@3405]) == YES, @"section info");
    XCTAssertTrue(([[formatter numberFromString:sections_info[@"sections"][4][@"section_id"]] isEqualToNumber:@3406]) == YES, @"section info");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
