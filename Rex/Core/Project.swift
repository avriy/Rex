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
		let priority: [Int : String]
		let resolution: [Int : String]
		let version: Int
		
		static let start = Schema(priority: [0 : "low", 1 : "medium", 2 : "high"],
		                          resolution: [1 : "open", 2 : "resolved", 3 : "reopened"],
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
