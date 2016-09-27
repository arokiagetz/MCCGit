//
//  navigationTests_landscape.swift
//  phoenix-reader
//
//  Created by Ismael Torres on 4/27/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

import Foundation
import XCTest

class navigationTests_landscape: XCTestCase {
    
    let window = XCUIApplication().windows.elementBoundByIndex(0)
    let device = XCUIDevice.sharedDevice()
    
    override func setUp() {
        super.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        let device = XCUIDevice.sharedDevice()
        device.orientation = UIDeviceOrientation.LandscapeLeft
        
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
        MSSFScreen.storyListHideButton.tap()
        XCTAssertTrue(MSSFScreen.storyListHideButton.hittable)
        XCTAssertFalse(MSSFScreen.storyList.hittable)
    }
    
    // Tests that after rotation from landscape to portrait,
    // the story list is hidden
    func testRotateStoryList() {
        device.orientation = UIDeviceOrientation.Portrait
        waitForNotHittable(MSSFScreen.storyList, waitSeconds: 3)
        XCTAssertFalse(MSSFScreen.storyList.hittable)
    }
    
    // Test that main story cell resizes correctly when story list
    // is opened or closed
    func testStoryCellResize() {
        // Get width of screen
        let coordinate = window.coordinateWithNormalizedOffset(CGVectorMake(1, 1))
        let windowWidth = coordinate.screenPoint.x
        
        // Assert that the size of the main story cell and the story list
        // equal the size of the screen(they are not overlapping)
        XCTAssertEqual(round(MSSFScreen.mainStory.frame.size.width) + MSSFScreen.storyList.frame.size.width, windowWidth)
        
        // Assert that after closing the story list the size of the main story
        // cell spans the full width of the screen
        MSSFScreen.storyListHideButton.tap()
        waitForNotHittable(MSSFScreen.storyList, waitSeconds: 3)
        XCTAssertEqual(round(MSSFScreen.mainStory.frame.size.width), windowWidth)
        
        // Open story list again, assert that main story
        // has switched back correctly
        MSSFScreen.storyListHideButton.tap()
        waitForHittable(MSSFScreen.storyList, waitSeconds: 3)
        XCTAssertEqual(round(MSSFScreen.mainStory.frame.size.width) + MSSFScreen.storyList.frame.size.width, windowWidth)
    }
    
    
}
