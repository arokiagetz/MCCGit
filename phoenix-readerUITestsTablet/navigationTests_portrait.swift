//
//  phoenix_readerUITestsTablet.swift
//  phoenix-readerUITestsTablet
//
//  Created by Ismael Torres on 4/27/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

import XCTest

class navigationTests_portrait: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        let device = XCUIDevice.sharedDevice()
        device.orientation = UIDeviceOrientation.Portrait
        
        XCUIApplication().launch()

    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // Tests that when the story list navigation button is
    // tapped, the button remains visible and the story list
    // is hidden
    func testCloseStoryList() {
        XCTAssertTrue(MSSFScreen.storyList.hittable)
        XCUIApplication().otherElements["PopoverDismissRegion"].tap()
        XCTAssertTrue(MSSFScreen.storyListHideButton.hittable)
        XCTAssertFalse(MSSFScreen.storyList.exists)
    }
    
}
