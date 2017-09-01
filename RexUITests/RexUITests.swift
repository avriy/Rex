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
			let text = "1234"
			textField.typeText(text + "\r")
			return text
		}
		
		XCTContext.runActivity(named: "Wait till project will appear") { (activity) in
			let acessibility = ProjectCollectionItem.textFieldAccessilityIdentifier(for: textEnterResult)
			let result = application.windows["Projects"].staticTexts[acessibility].waitForExistence(timeout: 20)
			XCTAssert(result, "Newly created project should appear in project list")
		}
    }
    
}
