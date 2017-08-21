//
//  RexTests.swift
//  RexTests
//
//  Created by Artemiy Sobolev on 16/08/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import XCTest
import CloudKit

@testable import Rex

extension TimeInterval {
	static let timeout: TimeInterval = 30
}

struct TestContext {
	let expectation: XCTestExpectation
	let appContext: AppContext
	let database = CKContainer.default().privateCloudDatabase
	let test: XCTestCase
	
	init(test: XCTestCase, description: String) {
		self.test = test
		let exp = test.expectation(description: description)
		appContext = AppContext(database: database) { error in
			XCTFail("Failed with \(error)")
			exp.fulfill()
		}
		expectation = exp
	}
	
	func saveAndWait<Representable: RecordRepresentable>(_ value: Representable) {
		appContext.save(value, completionHandler: expectation.fulfill)
		test.waitForExpectations(timeout: .timeout, handler: nil)
	}
}

class RexTests: XCTestCase {
	
	let database = CKContainer.default().privateCloudDatabase
	
	func createAppContext(for expectaion: XCTestExpectation) -> AppContext {
		return AppContext(database: database) { error in
			XCTFail("Failed with \(error)")
			expectaion.fulfill()
		}
	}
	
    func testCreateProject() {
		let testContext = TestContext(test: self, description: "Can create project")
		let project = Project(name: "Dummy")
		testContext.saveAndWait(project)
    }
	
	func testCanCreateIssue() {
		let exp = expectation(description: "Can create issue")
		let rex = createAppContext(for: exp)
		let project = Project(name: "New project")
		let issue = project.newIssue("New issue", description: "Need to do something")

		rex.save(project) {
			rex.save(issue) {
				exp.fulfill()
			}
		}
		waitForExpectations(timeout: .timeout, handler: nil)
	}
	
	func testCreateAndFetchProject() {
		let exp = expectation(description: "Can create and fetch project")
		let rex = createAppContext(for: exp)
		let project = Project(name: "Test project")
		
		let saveOperation = [project].saveOperation()
		
		let fetchOperation = CKFetchRecordsOperation(recordIDs: [project.record.recordID])
		fetchOperation.addDependency(saveOperation)
		
		fetchOperation.fetchRecordsCompletionBlock = { (dictionary, error) in
			if let error = error {
				XCTFail("Failed with error \(error)")
			}
			exp.fulfill()
		}

		rex.database.add(saveOperation)
		rex.database.add(fetchOperation)
		waitForExpectations(timeout: .timeout, handler: nil)
	}
	
	func testSaveProjectWithCustomSchema() {
		var schema = Schema.start
		let invalid = Schema.Resolution(identifier: 4, title: "Invalid")
		schema.resolutions.append(invalid)
		let testContext = TestContext(test: self, description: "Can create project with custom schema")
		let project = Project(name: "Custom schema project", schema: schema)
		testContext.saveAndWait(project)
	}
	
	override func tearDown() {
		super.tearDown()
		let exp = expectation(description: "Can tear down the projects")
		let rex = createAppContext(for: exp)
		rex.projects { result in
			rex.remove(result) {
				exp.fulfill()
			}
		}
		waitForExpectations(timeout: .timeout, handler: nil)
	}
	
}
