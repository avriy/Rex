//
//  User.swift
//  Rex
//
//  Created by Artemiy Sobolev on 22/08/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit

struct Junction: RecordRepresentable {
	
	let userRecordID: CKRecordID
	let projectID: CKRecordID
	var isActive: Bool
	let systemFields: Data
	
	init(userRecordID: CKRecordID, projectID: CKRecordID, isActive: Bool = false) {
		let record = CKRecord(recordType: Junction.recordType)
		self.userRecordID = userRecordID
		self.projectID = projectID
		self.isActive = isActive
		self.systemFields = record.archivedSystemFields()
	}
	
	enum CodingKeys: String, KeyCodable {
		case user, project, isActive
	}
	
	static let recordType: String = "Junction"
	
	init(record: CKRecord) throws {
		userRecordID = try record.getRecordID(for: CodingKeys.user)
		projectID = try record.getRecordID(for: CodingKeys.project)
		systemFields = record.archivedSystemFields()
		isActive = try record.getValue(for: CodingKeys.isActive)
	}
	
	var record: CKRecord {
		guard let result = CKRecord.unarchivedSystemFields(from: systemFields) else {
			fatalError("Can not unarchave system fields")
		}
		
		result[CodingKeys.user] = CKReference(recordID: userRecordID, action: .deleteSelf)
		result[CodingKeys.project] = CKReference(recordID: projectID, action: .deleteSelf)
		result[CodingKeys.isActive] = isActive as CKRecordValue
		
		return result
	}
}
