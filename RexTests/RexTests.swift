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

class RexTests: XCTestCase {
	
	let database = CKContainer.default().privateCloudDatabase
	
	func createAppContext(for expectaion: XCTestExpectation) -> AppContext {
		return AppContext(database: database) { error in
			XCTFail("Failed with \(error)")
			expectaion.fulfill()
		}
	}
	
    func testCreateProject() {
		let exp = expectation(description: "Can create project")
		let rex = createAppContext(for: exp)
		let project = Project(name: "Dummy")
		rex.save(project) {
			exp.fulfill()
		}
		waitForExpectations(timeout: .timeout, handler: nil)
    }
	
	func testCanCreateIssue() {
		let exp = expectation(description: "Can create issue")
		let rex = createAppContext(for: exp)
		let project = Project(name: "New project")
		let issue = Issue(project: project, name: "New issue", description: "Need to do something", resolution: 0, priority: 0)
		
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
