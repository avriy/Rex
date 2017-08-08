//
//  Project.swift
//  Rex
//
//  Created by Artemiy Sobolev on 25/07/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit

@objc
class Project: NSObject, RecordRepresentable {
	
	@objc var name: String
	
	static let recordType: String = "Project"
	var recordID: CKRecordID {
		guard let record = CKRecord.unarchivedSystemFields(from: systemFields) else {
			fatalError()
		}
		return record.recordID
	}
	
	var systemFields: Data
	
	init(name: String) {
		self.name = name
		let record = CKRecord(recordType: "Project")
		self.systemFields = record.archivedSystemFields()
	}

	required init?(record: CKRecord) {
		guard let name = record["name"] as? String else {
			return nil
		}
		self.name = name
		self.systemFields = record.archivedSystemFields()
	}
	
	var record: CKRecord {
		guard let result = CKRecord.unarchivedSystemFields(from: systemFields) else {
			fatalError()
		}
		result["name"] = name as CKRecordValue
		
		return result
	}
}
