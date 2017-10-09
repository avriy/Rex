//
//  CloudKitContextTests.swift
//  RexTests
//
//  Created by Artemiy Sobolev on 09/10/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import XCTest
@testable import RexKit
import CloudKit

class DummyMetadataStore: MetadataStore {
	private(set) var dictionary = [String : Data]()
	
	func recordID(for identifier: String) -> CKRecordID {
		return CKRecordID(recordName: identifier)
	}
	
	func identifier(for recordID: CKRecordID) -> String {
		return recordID.recordName
	}
	
	func save(data: Data, forKey key: String) {
		dictionary[key] = data
	}
	
	func getData(for key: String) -> Data? {
		return dictionary[key]
	}
}

struct Puppy: Codable, Identifiable {
	let id: String
	let name: String
	
	init(id: String = UUID().uuidString, name: String) {
		self.id = id; self.name = name
	}
}

class CloudKitContextTests: XCTestCase {

	let context = CloudKitContext(metadataStore: DummyMetadataStore())

    func testPuppy() throws {
		
		let puppy = Puppy(name: "Barsik")
		let record = try context.record(for: puppy)
		let puppyBack: Puppy = try context.value(from: record)
		XCTAssert(puppy.id == puppyBack.id)
		XCTAssert(puppy.name == puppyBack.name)
		let nextRecord = try context.record(for: puppyBack)
		XCTAssert(nextRecord.archivedSystemFields() == record.archivedSystemFields())
    }
}
