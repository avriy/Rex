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
	static let timeout: TimeInterval = 10
}

class RexTests: XCTestCase {
	
	let database = CKContainer.default().privateCloudDatabase
	
	func createRex(for expectaion: XCTestExpectation) -> Rex {
		return Rex(database: database) { error in
			XCTFail("Failed with \(error)")
			expectaion.fulfill()
		}
	}
	
    func testCreateProject() {
		let exp = expectation(description: "Can create project")
		let rex = createRex(for: exp)
		let project = Project(name: "Dummy")
		rex.save(project) {
			exp.fulfill()
		}
		waitForExpectations(timeout: .timeout, handler: nil)
    }
	
	func testCanCreateIssue() {
		let exp = expectation(description: "Can create issue")
		let rex = createRex(for: exp)
		let project = Project(name: "New project")
		let issue = Issue(name: "New issue", description: "Need to do something", resolution: .open, project: project)
		
		rex.save(project) {
			rex.save(issue) {
				exp.fulfill()
			}
		}
		waitForExpectations(timeout: .timeout, handler: nil)
	}
	
	func testCreateAndFetchProject() {
		let project = Project(name: "Dummy")
		let exp = expectation(description: "Can create and fetch project")
		let rex = createRex(for: exp)
		
		rex.save(project) {
			debugPrint("Project with id \(project.recordID.recordName) is saved")
			rex.projects { projects in
				let result = projects.contains { $0.recordID.recordName == project.recordID.recordName }
				XCTAssert(result, "Fetched projects should contain project that was saved")
				exp.fulfill()
			}
		}
		waitForExpectations(timeout: .timeout, handler: nil)
	}
	
	override func tearDown() {
		super.tearDown()
		let exp = expectation(description: "Can tear down the projects")
		let rex = createRex(for: exp)
		rex.projects { result in
			rex.remove(result) {
				exp.fulfill()
			}
		}
		waitForExpectations(timeout: .timeout, handler: nil)
	}
	
}
