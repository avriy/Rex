//
//  Project.swift
//  Rex
//
//  Created by Artemiy Sobolev on 25/07/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit
import Cocoa

@objc
class Project: NSObject, RecordRepresentable {
	
	static let recordType: String = "Project"
	
	@objc dynamic var name: String
	private(set) var schema: Schema
	var imageURL: URL?
    
    private enum CodingKeys: String, KeyCodable {
        case name, schema, imageAsset
    }
	
	var recordID: CKRecordID {
		guard let record = CKRecord.unarchivedSystemFields(from: systemFields) else {
			fatalError()
		}
		return record.recordID
	}
	
	private var systemFields: Data
	
	init(name: String, schema: Schema = .start, imageURL: URL? = nil) {
		self.name = name
		self.schema = schema
		self.imageURL = imageURL
		let record = CKRecord(recordType: "Project")
		systemFields = record.archivedSystemFields()
	}

	required init(record: CKRecord) throws {
        
        name = try record.getValue(for: CodingKeys.name)
        systemFields = record.archivedSystemFields()
		
		let decoder = JSONDecoder()
		if let schemaData = record[CodingKeys.schema.rawValue] as? Data,
            let schema = try? decoder.decode(Schema.self, from: schemaData) {
			self.schema = schema
		} else {
			self.schema = .start
		}
		
		self.imageURL = (record[CodingKeys.imageAsset.rawValue] as? CKAsset)?.fileURL
		
	}
	
	var record: CKRecord {
		guard let result = CKRecord.unarchivedSystemFields(from: systemFields) else {
			fatalError()
		}
        
        result[CodingKeys.name] = name as CKRecordValue
        
		if let data = try? JSONEncoder().encode(schema) {
			result[CodingKeys.schema] = data as CKRecordValue
		}

		if let imageURL = imageURL {
			result[CodingKeys.imageAsset] = CKAsset(fileURL: imageURL)
		}
		
		return result
	}
	
	/// Creates issue with default `Priority` and default `Resolution`
	///
	/// - Parameters:
	///   - title: Title of an issue
	///   - description: Descrition of a new issue
	/// - Returns: new `Issue`
	func newIssue(_ title: String, description: String) -> Issue {
		return Issue(project: self, name: title, description: description, resolution: schema.defaultResolution, priority: schema.defaultPriority)
	}
	
	// MARK: - Project migration
	/// Migrates project to a new schema with validating migration
	///
	/// - Parameter target: new `Schema` to migrate to
	/// - Throws: all possible values of `Project.Schema.MigrationError`
    func migrate(with migrator: SchemaMigrator = BasicSchemaMigrator(), to target: Schema) throws {
        try migrator.migrate(from: schema, to: target)
		schema = target
	}
}
