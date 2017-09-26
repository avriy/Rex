//
//  SchemeMigrationTests.swift
//  RexTests
//
//  Created by Artemiy Sobolev on 20/08/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import XCTest
@testable import RexKit

class SchemeMigrationTests: XCTestCase {

    func testAddNewResolution() {
		var schema = Schema.start
		let newResolution = Schema.Resolution(identifier: 4, title: "New resolution")
		schema.resolutions.append(newResolution)
		do {
			try BasicSchemaMigrator().migrate(from: .start, to: schema)
		} catch {
			XCTFail("Failed with error \(error)")
		}
    }
	
	func testEmptyResolutionsMigration() {
		var emtyResolutionsSchema = Schema.start
		emtyResolutionsSchema.resolutions = []
		do {
            try BasicSchemaMigrator().migrate(from: .start, to: emtyResolutionsSchema)
			XCTFail("Migration should fail with \(Schema.MigrationError.emptySchema)")
		} catch Schema.MigrationError.emptySchema {
		} catch {
			XCTFail("Migration should fail with \(Schema.MigrationError.emptySchema), not with \(error)")
		}
	}
	
	func testEmptyPrioritiesMigration() {
		var emtyResolutionsSchema = Schema.start
		emtyResolutionsSchema.priorities = []
		do {
			try BasicSchemaMigrator().migrate(from: .start, to: emtyResolutionsSchema)
			XCTFail("Migration should fail with \(Schema.MigrationError.emptySchema)")
		} catch Schema.MigrationError.emptySchema {
		} catch {
			XCTFail("Migration should fail with \(Schema.MigrationError.emptySchema), not with \(error)")
		}
	}

	func testIssueMigration() {
		let project = Project(name: "Test project")
		let issue = project.newIssue("New issue", description: "")
		var schema = Schema.start
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
