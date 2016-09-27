//
//  phoenix_readerUITests.swift
//  phoenix-readerUITests
//
//  Created by Ismael Torres on 4/4/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

import XCTest

class navigationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Stop immediately when a failure occurs.
        continueAfterFailure = false
        
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
        
    func testMSSFStoriesExist() {
        let storyCount = MSSFScreen.stories.count
        XCTAssertNotEqual(storyCount, 0)
    }

    func testSettingsButtonExists() {
        XCTAssert(MSSFScreen.settingsButton.exists)
    }
    
    func testWeatherButtonExists() {
        XCTAssert(MSSFScreen.weatherButton.exists)
    }
}
