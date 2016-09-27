//
//  mssf_screen.swift
//  phoenix-reader
//
//  Created by Ismael Torres on 4/5/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

import Foundation
import XCTest

class MSSFScreen: NSObject {
    static let weatherButton = XCUIApplication().navigationBars["MasterView"].buttons["Weather"]
    static let settingsButton = XCUIApplication().navigationBars["MasterView"].buttons["Settings"]
    
    static let storyList = XCUIApplication().tables.elementBoundByIndex(0)
    static let stories = XCUIApplication().tables.elementBoundByIndex(0).cells
    
    static let mainStory = XCUIApplication().collectionViews.elementBoundByIndex(0)
    
    static let storyListHideButton = XCUIApplication().navigationBars["DetailView"].buttons["StorylistHide"]
}