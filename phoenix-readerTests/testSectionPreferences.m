//
//  testSectionPreferences.m
//  phoenix-reader
//
//  Created by Sarat Chandran on 3/14/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNISectionPreferencesHandler.h"
#import "SectionPreferences.h"

@interface testSectionPreferences : XCTestCase

@end

@implementation testSectionPreferences

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (BOOL)checkSectionIDOrderForSectionPreferencesHandler:(MNISectionPreferencesHandler *) sectionPreferencesHandler withExpectedSectionIDs:(NSArray<NSString *> *)expectedOrderedSectionIds
{
    __block BOOL result = YES;
    
    NSError *error = nil;
    NSArray<NSString *> *sectionIDs = [sectionPreferencesHandler retrieveOrderedSectionIDsWithError:&error];
    XCTAssertNil(error, @"error fetching ordered section preferences: %@", error);
    // compare each item to expected order
    for (NSUInteger i = 0; i < sectionIDs.count; i++) {
        NSString *aSectionID = sectionIDs[i];
        NSString *expectedSectionID = expectedOrderedSectionIds[i];
        BOOL matched = [aSectionID isEqualToString:expectedSectionID];
        // NSLog(@"compare: index=%ld, expected = %@, found = %@, match = %@", (long)i, expectedSectionID, aSectionID, (matched ? @"Y" : @"N"));
        XCTAssertTrue(matched, @"sections out of order at %ld: expecting %@, found %@", (long)i, expectedSectionID, aSectionID);
        if (matched == NO) result = NO;
    }
    
    return result;
}

- (void)testLoadPreferences {
    MNISectionPreferencesHandler* sectionPreferencesHandler = [[MNISectionPreferencesHandler alloc] init];
    
    // clear the preferences
    NSError *error = [sectionPreferencesHandler clearSectionPreferences];
    XCTAssertNil(error, @"clear preferences");
    
    // set up test preferences
    NSArray<NSString *> *sectionIDs = @[ @"first", @"second", @"third", @"fourth", @"fifth" ];
    error = [sectionPreferencesHandler storeOrderedSectionIDs:sectionIDs];
    XCTAssertNil(error, @"save preferences");
    
    // verify preferences were saved
    error = nil;
    sectionIDs = [sectionPreferencesHandler retrieveOrderedSectionIDsWithError:&error];
    XCTAssertNil(error, @"fetch preferences");
    XCTAssertEqual(sectionIDs.count, 5, @"preferences saved");

    // move some things around
    error = [sectionPreferencesHandler moveSectionID:@"first" beforeSectionID:@"fourth"];
    XCTAssertNil(error, @"move preferences");
    error = [sectionPreferencesHandler moveSectionID:@"fifth" beforeSectionID:@"third"];
    XCTAssertNil(error, @"move preferences");
    error = [sectionPreferencesHandler moveSectionID:@"second" beforeSectionID:nil];
    XCTAssertNil(error, @"move preferences");

    // verify items are where we expected
    [self checkSectionIDOrderForSectionPreferencesHandler:sectionPreferencesHandler withExpectedSectionIDs:@[ @"fifth", @"third", @"first", @"fourth", @"second" ]];
    
    // add an item
    error = [sectionPreferencesHandler addSectionID:@"sixth" beforeSectionID:@"fifth"];
    XCTAssertNil(error, @"move preferences");
    
    // verify items are where we expected
    [self checkSectionIDOrderForSectionPreferencesHandler:sectionPreferencesHandler withExpectedSectionIDs:@[ @"sixth", @"fifth", @"third", @"first", @"fourth", @"second" ]];

    // delete an item
    error = [sectionPreferencesHandler deleteSectionID:@"fourth"];
    XCTAssertNil(error, @"move preferences");

    // verify items are where we expected
    [self checkSectionIDOrderForSectionPreferencesHandler:sectionPreferencesHandler withExpectedSectionIDs:@[ @"sixth", @"fifth", @"third", @"first", @"second" ]];
    
}

- (void)testSectionPreferenceSorting
{
    NSArray *sampleSectionIds = @[ @"alpha", @"bravo", @"charlie", @"delta", @"echo", @"foxtrot", @"golf", @"hotel", @"indigo", @"juliet", @"kilo", @"lima", @"mike", @"november", @"oscar", @"papa", @"quebec", @"romeo", @"sierra", @"tango", @"uniform", @"victor", @"whiskey", @"x-ray", @"yankee", @"zulu", @"uno", @"dos", @"tres", @"cuatro", @"cinco", @"seis", @"siete", @"ocho", @"nueve", @"diez" ];
    
    MNISectionPreferencesHandler* sectionPreferencesHandler = [[MNISectionPreferencesHandler alloc] init];
    NSError *error = nil;
    error = [sectionPreferencesHandler clearSectionPreferences];
    XCTAssertNil(error, @"clear preferences");

    error = [sectionPreferencesHandler storeOrderedSectionIDs:sampleSectionIds];
    XCTAssertNil(error, @"save preferences");
    
    NSUInteger timesToReorder = 25;
    for (NSInteger j = 0; j < timesToReorder; j++) {
        
        NSArray<NSString *> *fetchedSectionIDs = [sectionPreferencesHandler retrieveOrderedSectionIDsWithError:&error];
        XCTAssertNil(error, @"fetch preferences");
        
        // move
        NSString *beforeID = fetchedSectionIDs[2];
        NSString *toMoveID = [fetchedSectionIDs lastObject];
        error = [sectionPreferencesHandler moveSectionID:toMoveID beforeSectionID:beforeID];
        XCTAssertNil(error, @"move");
    }
    
    NSArray<NSString *> *expectedSectionIDs = @[ @"alpha", @"bravo", @"lima", @"mike", @"november", @"oscar", @"papa", @"quebec", @"romeo", @"sierra", @"tango", @"uniform", @"victor", @"whiskey", @"x-ray", @"yankee", @"zulu", @"uno", @"dos", @"tres", @"cuatro", @"cinco", @"seis", @"siete", @"ocho", @"nueve", @"diez", @"charlie", @"delta", @"echo", @"foxtrot", @"golf", @"hotel", @"indigo", @"juliet", @"kilo" ];
    [self checkSectionIDOrderForSectionPreferencesHandler:sectionPreferencesHandler withExpectedSectionIDs:expectedSectionIDs];
}

@end
