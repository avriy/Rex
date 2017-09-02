//
//  RexUITests.swift
//  RexUITests
//
//  Created by Artemiy Sobolev on 01/09/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import XCTest
@testable import Rex

class RexUITests: XCTestCase {
	
    func testCanCreateProject() {
        let application = XCUIApplication()
		application.launchArguments += ["TEST"]
		application.launch()
		
		XCTContext.runActivity(named: "Opening project creation VC") { (activity) in
			application.windows["Projects"].firstMatch.collectionViews.images["add"].click()
		}
		
		let textEnterResult = XCTContext.runActivity(named: "Creating project") { (activity) -> String in
			let textField = application.windows["Create new project"].children(matching: .textField).element
			textField.click()
			let text = String(UUID().uuidString.suffix(6))
			textField.typeText(text)
			textField.typeKey(.enter, modifierFlags: [])
			return text
		}
		
		XCTContext.runActivity(named: "Wait till project will appear") { (activity) in
			print("Waiting for \(textEnterResult)")
			let result = application.windows["Projects"].staticTexts[textEnterResult].waitForExistence(timeout: 10)
			XCTAssert(result, "Newly created project should appear in project list")
		}
    }
    
}
