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
		
		self.imageURL = (record["imageAsset"] as? CKAsset)?.fileURL
		
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

		if let imageURL = imageURL {
			result["imageAsset"] = CKAsset(fileURL: imageURL)
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

struct BasicSchemaMigrator: SchemaMigrator {
    
    func migrate(from current: Schema, to target: Schema) throws {

        guard !target.priorities.isEmpty else {
            throw Schema.MigrationError.emptySchema
        }
        
        guard !target.resolutions.isEmpty else {
            throw Schema.MigrationError.emptySchema
        }
        
        if current.resolutions != target.resolutions {
            
            let targetResolutionIDs = Set(target.resolutions.map { $0.identifier })
            let currentResolutionIDs = Set(current.resolutions.map { $0.identifier })
            
            guard targetResolutionIDs.count == target.resolutions.count else {
                // dublicating resolutions
                throw Schema.MigrationError.invalidSchema
            }
            
            let idsToCreate = targetResolutionIDs.subtracting(currentResolutionIDs)
            let maxCurrentID = currentResolutionIDs.max()!
            for idToCreate in idsToCreate {
                guard maxCurrentID < idToCreate else {
                    throw Schema.MigrationError.invalidSchema
                }
            }
        }
        
        if current.priorities != target.priorities {
            //    new priorities must be in ascending order
            _ = try target.priorities.reduce(-1) {
                guard $0 < $1.identifier else {
                    throw Schema.MigrationError.invalidSchema
                }
                return $1.identifier
            }
        }
    }
}

protocol SchemaMigrator {
    func migrate(from current: Schema, to target: Schema) throws
}
