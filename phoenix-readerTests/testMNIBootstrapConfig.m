//
//  phoenix_readerTests.m
//  phoenix-readerTests
//
//  Created by Scott Ferwerda on 12/22/15.
//  Copyright © 2015 The McClatchy Company. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNIBootstrapConfig.h"
#import "UIColor+ColorHelpers.h"

@interface phoenix_readerTests : XCTestCase

@end

@implementation phoenix_readerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBootstrapLoad {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    MNIBootstrapConfig *bootstrapConfig = [MNIBootstrapConfig sharedInstance];
    XCTAssertTrue([[[[MNIBootstrapConfig menuTextColor] hexValue] lowercaseString] isEqualToString:@"ffffff"], @"pick default config file from info.plist");
    [bootstrapConfig setBootStrapConfigFile:@"configBad.json"];
    XCTAssertTrue([[[[MNIBootstrapConfig menuTextColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    [bootstrapConfig setBootStrapConfigFile:@"config.txt"];
    XCTAssertTrue([[[[MNIBootstrapConfig menuTextColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
}

- (void)testFullConfig {
    MNIBootstrapConfig *bootstrapConfig = [MNIBootstrapConfig sharedInstance];
    NSDictionary* config = @{
        @"server_config_url":@"https://qa1-api.krabc.com/mobile-api/v1/config/1.0/bellinghamherald",
        @"UI":@{
            @"BarTintColor":@"0083cb",
            @"BarTitleColor":@"ffffff",
            @"TintColor":@"ffffff",
            @"StatusBarColorLight":@true,
            @"SectionsMenuColor":@"037BC0",
            @"SectionsMenuTintColor":@"DDDDDD",
            @"SectionsMenuTextColor":@"FFFFFF",
            @"SectionsMenuHighlightColor":@"f5fcff",
            @"SectionsMenuHighlightTextColor":@"037BC0",
            @"CellSelectionColor":@"d9d9d9"
        }
    };
    [bootstrapConfig setBootStrapWithJSONDictionary:config];
    XCTAssertTrue([[MNIBootstrapConfig serverConfigUrl] isEqualToString:@"https://qa1-api.krabc.com/mobile-api/v1/config/1.0/bellinghamherald"]);
    XCTAssertTrue([[[[MNIBootstrapConfig menuTextColor] hexValue] lowercaseString] isEqualToString:@"ffffff"]);
    XCTAssertTrue([[[[MNIBootstrapConfig menuBackgroundColor] hexValue] lowercaseString] isEqualToString:@"037bc0"]);
    XCTAssertTrue([[[[MNIBootstrapConfig menuTintColor] hexValue] lowercaseString] isEqualToString:@"dddddd"]);
    XCTAssertTrue([[[[MNIBootstrapConfig menuHighlightBackgroundColor] hexValue] lowercaseString] isEqualToString:@"f5fcff"]);
    XCTAssertTrue([[[[MNIBootstrapConfig menuHighlightTextColor] hexValue] lowercaseString] isEqualToString:@"037bc0"]);
    XCTAssertTrue([[[[MNIBootstrapConfig navMenuTintColor] hexValue] lowercaseString] isEqualToString:@"dddddd"]);
    XCTAssertTrue([[[[MNIBootstrapConfig barTintColor] hexValue] lowercaseString] isEqualToString:@"0083cb"]);
    XCTAssertTrue([[[[MNIBootstrapConfig barTitleColor] hexValue] lowercaseString] isEqualToString:@"ffffff"]);
    XCTAssertTrue([[[[MNIBootstrapConfig tintColor] hexValue] lowercaseString] isEqualToString:@"ffffff"]);
    XCTAssertTrue([[[[MNIBootstrapConfig sectionsMenuTintColor] hexValue] lowercaseString] isEqualToString:@"dddddd"]);
    XCTAssertTrue([[[[MNIBootstrapConfig sectionsMenuTextColor] hexValue] lowercaseString] isEqualToString:@"ffffff"]);
    XCTAssertTrue([[[[MNIBootstrapConfig sectionsMenuColor] hexValue] lowercaseString] isEqualToString:@"037bc0"]);
    XCTAssertTrue([[[[MNIBootstrapConfig sectionsMenuHighlightColor] hexValue] lowercaseString] isEqualToString:@"f5fcff"]);
    XCTAssertTrue([[[[MNIBootstrapConfig sectionsHighlightMenuTextColor] hexValue] lowercaseString] isEqualToString:@"037bc0"]);
}

- (void)testPartialConfig {
    MNIBootstrapConfig *bootstrapConfig = [MNIBootstrapConfig sharedInstance];
    NSDictionary* config = @{
                             @"UI":@{
                                     @"BarTintColor":@"0083cb",
                                     @"BarTitleColor":@"ffffff",
                                     @"TintColor":@"ffffff",
                                     @"StatusBarColorLight":@true,
                                     @"CellSelectionColor":@"d9d9d9"
                                     }
                             };
    [bootstrapConfig setBootStrapWithJSONDictionary:config];
    XCTAssertNil([MNIBootstrapConfig serverConfigUrl]);

    XCTAssertTrue([[[[MNIBootstrapConfig menuTextColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig menuBackgroundColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig menuTintColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig navMenuTintColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig menuHighlightBackgroundColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig menuHighlightTextColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
}

- (void)testEmptyConfig {
    MNIBootstrapConfig *bootstrapConfig = [MNIBootstrapConfig sharedInstance];
    NSDictionary* config = @{
               @"UI":@{
                       }
               };
    [bootstrapConfig setBootStrapWithJSONDictionary:config];
    XCTAssertTrue([[[[MNIBootstrapConfig menuTextColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig menuBackgroundColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig menuTintColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig menuHighlightBackgroundColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig menuHighlightTextColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig navMenuTintColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig navMenuTintColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig navMenuTintColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig navMenuTintColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig navMenuTintColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig navMenuTintColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig navMenuTintColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig navMenuTintColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
    XCTAssertTrue([[[[MNIBootstrapConfig sectionsHighlightMenuTextColor] hexValue] lowercaseString] isEqualToString:@"000000"]);
}

@end
