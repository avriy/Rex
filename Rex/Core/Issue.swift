//
//  Issue.swift
//  Rex
//
//  Created by Artemiy Sobolev on 28/06/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit

class Issue: NSObject, RecordRepresentable {
	
	@objc enum Resolution: Int {
		case open, resolved, reopened
	}
	
	@objc enum Priority: Int {
		case low, medium, high
	}
	
	@objc dynamic var name: String
	@objc dynamic var details: String
	
	@objc dynamic var resolution: Resolution
	@objc dynamic var priority: Priority
	
	@objc dynamic var assigneeID: CKRecordID?
	@objc dynamic let projectID: CKRecordID
	
	
	@objc var creationDate: Date? {
		return record.creationDate
	}
	
	static let recordType: String = "Issue"
	
	private var systemFields: Data
	
	private enum CodingKeys: String {
		case name, description, resolution, assigneeID, projectID, priority
	}
	
	override var hashValue: Int {
		let assigneeHash = assigneeID?.hashValue ?? 0
		let projectHash = projectID.hashValue
		return name.hashValue ^ details.hashValue ^ systemFields.hashValue ^ resolution.hashValue ^ assigneeHash ^ projectHash
	}
	
	init(project: Project, name: String, description: String, resolution: Resolution, priority: Priority) {
		let record = CKRecord(recordType: "Issue")
		self.name = name
		self.details = description
		self.resolution = resolution
		self.projectID = project.recordID
		self.priority = priority
		systemFields = record.archivedSystemFields()
	}
	
	required init?(record: CKRecord) {
		systemFields = record.archivedSystemFields()
		guard let name = record[CodingKeys.name.rawValue] as? String,
			let description = record[CodingKeys.description.rawValue] as? String,
			let rawResolution = record[CodingKeys.resolution.rawValue] as? Int,
			let resolution = Resolution(rawValue: rawResolution),
			let rawPriority = record[CodingKeys.priority.rawValue] as? Int,
			let priority = Priority(rawValue: rawPriority),
			let projectID = record[CodingKeys.projectID.rawValue] as? CKReference else {
				return nil
		}
		self.name = name
		self.details = description
		self.resolution = resolution
		self.priority = priority
		self.projectID = projectID.recordID
		self.assigneeID = (record[CodingKeys.assigneeID.rawValue] as? CKReference)?.recordID
	}
	
	var record: CKRecord {
		guard let result = CKRecord.unarchivedSystemFields(from: systemFields) else {
			fatalError()
		}
		
		result[CodingKeys.name.rawValue] = name as CKRecordValue
		result[CodingKeys.description.rawValue] = details as CKRecordValue
		result[CodingKeys.resolution.rawValue] = resolution.rawValue as CKRecordValue
		result[CodingKeys.priority.rawValue] = priority.rawValue as CKRecordValue
		result[CodingKeys.assigneeID.rawValue] = assigneeID.map { CKReference(recordID: $0, action: .deleteSelf) }
		result[CodingKeys.projectID.rawValue] = CKReference(recordID: projectID, action: .deleteSelf)
		return result
	}
}

