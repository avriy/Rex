//
//  RexUITests.swift
//  RexUITests
//
//  Created by Artemiy Sobolev on 28/06/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import XCTest

class RexUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
	func testCreateIssue() {
		
		let window = XCUIApplication().windows["Window"]
		window.buttons["add"].click()
		
		let cell = window/*@START_MENU_TOKEN@*/.tables/*[[".scrollViews.tables",".tables"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .tableRow).element(boundBy: 0).children(matching: .cell).element
		cell.typeText("Yo!")
		window.children(matching: .scrollView).element(boundBy: 1).children(matching: .textView).element.click()
		cell.typeText("description")
		
	}
    
}
