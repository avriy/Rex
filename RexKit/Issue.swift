//
//  Issue.swift
//  Rex
//
//  Created by Artemiy Sobolev on 28/06/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit

public class Issue: NSObject, RecordRepresentable {
	
	@objc public dynamic var name: String
	@objc public dynamic var details: String
	
	@objc public dynamic var resolutionID: Schema.Resolution.Identifier
	@objc public dynamic var priorityID: Schema.Priority.Identifier
	
	@objc public dynamic var assigneeID: CKRecordID?
	@objc public dynamic let projectID: CKRecordID
	
	@objc public var creationDate: Date? {
		return record.creationDate
	}
	
    public static let recordType: String = "Issue"
	
	private var systemFields: Data
	
	private enum CodingKeys: String, KeyCodable {
		case name, description, resolution, assigneeID, projectID, priority
	}
	
    override public var hashValue: Int {
		let assigneeHash = assigneeID?.hashValue ?? 0
		let projectHash = projectID.hashValue
		return name.hashValue ^ details.hashValue ^ systemFields.hashValue ^ resolutionID.hashValue ^ assigneeHash ^ projectHash ^ priorityID.hashValue
	}
	
	public init(project: Project, name: String, description: String, resolution: Schema.Resolution, priority: Schema.Priority) {
		let record = CKRecord(recordType: "Issue")
		self.name = name
		self.details = description
		self.resolutionID = resolution.identifier
		self.projectID = project.recordID
		self.priorityID = priority.identifier
		systemFields = record.archivedSystemFields()
		assert(project.schema.resolutions.contains(resolution))
		assert(project.schema.priorities.contains(priority))
	}
	
    required public init(record: CKRecord) throws {
		systemFields = record.archivedSystemFields()
        name = try record.getValue(for: CodingKeys.name)        
        details = try record.getValue(for: CodingKeys.description)
        resolutionID = try record.getValue(for: CodingKeys.resolution)
        priorityID = try record.getValue(for: CodingKeys.priority)
		projectID = try record.getRecordID(for: CodingKeys.projectID)
	}
	
    public var record: CKRecord {
		guard let result = CKRecord.unarchivedSystemFields(from: systemFields) else {
			fatalError()
		}
		
		result[CodingKeys.name] = name as CKRecordValue
		result[CodingKeys.description] = details as CKRecordValue
		result[CodingKeys.resolution] = resolutionID as CKRecordValue
		result[CodingKeys.priority] = priorityID as CKRecordValue
		result[CodingKeys.assigneeID] = assigneeID.map { CKReference(recordID: $0, action: .deleteSelf) }
		result[CodingKeys.projectID] = CKReference(recordID: projectID, action: .deleteSelf)
		return result
	}
}
