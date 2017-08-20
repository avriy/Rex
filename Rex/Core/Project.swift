//
//  Project.swift
//  Rex
//
//  Created by Artemiy Sobolev on 25/07/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit

extension Project {
	struct Schema: Codable {
		
		struct Priority: Codable {
			let identifier: Int
			let title: String
			
			static let low = Priority(identifier: 0, title: "low")
			static let medium = Priority(identifier: 1, title: "medium")
			static let high = Priority(identifier: 2, title: "high")
		}
		
		struct Resolution: Codable {
			let identifier: Int
			let title: String
			
			static let open = Resolution(identifier: 0, title: "open")
			static let resolved = Resolution(identifier: 1, title: "resolved")
			static let reopened = Resolution(identifier: 2, title: "reopened")
		}
		
		let priorities: [Priority]
		let resolution: [Resolution]
		let version: Int
		
		static let start = Schema(priorities: [.low, .medium, .high],
		                          resolution: [.open, .resolved, .reopened],
		                          version: 1)
	}
}

@objc
class Project: NSObject, RecordRepresentable {
	
	@objc dynamic var name: String
	let schema: Schema
	
	static let recordType: String = "Project"
	var recordID: CKRecordID {
		guard let record = CKRecord.unarchivedSystemFields(from: systemFields) else {
			fatalError()
		}
		return record.recordID
	}
	
	private var systemFields: Data
	
	init(name: String, schema: Schema = .start) {
		self.name = name
		self.schema = schema
		let record = CKRecord(recordType: "Project")
		systemFields = record.archivedSystemFields()
	}

	required init?(record: CKRecord) {
		guard let name = record["name"] as? String else {
			return nil
		}
		self.name = name
		let decoder = JSONDecoder()
		if let schemaData = record["schema"] as? Data, let schema = try? decoder.decode(Schema.self, from: schemaData) {
			self.schema = schema
		} else {
			self.schema = .start
		}
		systemFields = record.archivedSystemFields()
	}
	
	var record: CKRecord {
		guard let result = CKRecord.unarchivedSystemFields(from: systemFields) else {
			fatalError()
		}
		result["name"] = name as CKRecordValue
		if let data = try? JSONEncoder().encode(schema) {
			result["schema"] = data as CKRecordValue
		}
		
		return result
	}
}
