//
//  testFonts.swift
//  phoenix-reader
//
//  Created by Scott Ferwerda on 4/5/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

import XCTest

class testFonts: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // check that all the fonts we expect to be installed are, in fact, installed
    func testFonts() {

// this code will print out the names of all installed fonts
//        let fontFamilyNamesSorted = UIFont.familyNames().sort()
//        for family: String in fontFamilyNamesSorted
//        {
//            print("\(family)")
//            for names: String in UIFont.fontNamesForFamilyName(family)
//            {
//                print("== \(names)")
//            }
//        }

        let expectedFontNames = [ "LyonText-Regular", "LyonText-Bold",
            "McClatchySans-Demi", "McClatchySans-Regular",
            "McClatchySansCond-Medium", "McClatchySansCond-Demi", "McClatchySansCond-Regular", "McClatchySansCond-Light",
            "McClatchySlab-Medium", "McClatchySlab-Demi" ]
        
        var installedExpectedFontNames = Set<String>()
        for family: String in UIFont.familyNames() {
            for aName: String in UIFont.fontNamesForFamilyName(family) {
                if (expectedFontNames.contains(aName)) {
                   installedExpectedFontNames.insert(aName)
                }
            }
        }
        
        XCTAssertEqual(expectedFontNames.count, installedExpectedFontNames.count, "not all fonts are installed")
        
    }
    
}
