//
//  SchemeMigrationTests.swift
//  RexTests
//
//  Created by Artemiy Sobolev on 20/08/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import XCTest
@testable import Rex

class SchemeMigrationTests: XCTestCase {

    func testAddNewResolution() {
		let project = Project(name: "Test project")
		var schema = Project.Schema.start
		let newResolution = Project.Schema.Resolution(identifier: 4, title: "New resolution")
		schema.resolutions.append(newResolution)
		do {
			try project.migrate(to: schema)
		} catch {
			XCTFail("Failed with error \(error)")
		}
    }
	
	func testEmptyResolutionsMigration() {
		let project = Project(name: "Test project")
		var emtyResolutionsSchema = Project.Schema.start
		emtyResolutionsSchema.resolutions = []
		do {
			try project.migrate(to: emtyResolutionsSchema)
			XCTFail("Migration should fail with \(Project.Schema.MigrationError.emptySchema)")
		} catch Project.Schema.MigrationError.emptySchema {
		} catch {
			XCTFail("Migration should fail with \(Project.Schema.MigrationError.emptySchema), not with \(error)")
		}
	}
	
	func testEmptyPrioritiesMigration() {
		let project = Project(name: "Test project")
		var emtyResolutionsSchema = Project.Schema.start
		emtyResolutionsSchema.priorities = []
		do {
			try project.migrate(to: emtyResolutionsSchema)
			XCTFail("Migration should fail with \(Project.Schema.MigrationError.emptySchema)")
		} catch Project.Schema.MigrationError.emptySchema {
		} catch {
			XCTFail("Migration should fail with \(Project.Schema.MigrationError.emptySchema), not with \(error)")
		}
	}

	func testIssueMigration() {
		let project = Project(name: "Test project")
		let issue = project.newIssue("New issue", description: "")
		var schema = Project.Schema.start
		schema.resolutions.remove(at: 0)
		XCTAssert(project.schema.resolution(for: issue) != nil, "Issue must have a resolution")

		do {
			try project.migrate(to: schema)
		} catch {
			XCTFail("Failed with \(error)")
		}
		XCTAssert(project.schema.resolution(for: issue) == nil, "After migration this resolution is removed")
	}
	
}
