//
//  Issue.swift
//  Rex
//
//  Created by Artemiy Sobolev on 28/06/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit

protocol RecordRepresentable {
	init?(record: CKRecord)
	var record: CKRecord { get }
}

class Issue: NSObject, RecordRepresentable {
	
	@objc enum Resolution: Int {
		case open, resolved, reopened
	}
	
	@objc dynamic var name: String
	@objc dynamic var details: String
	
	@objc dynamic var resolution: Resolution
	private var systemFields: Data
	
	private enum CodingKeys: String {
		case name, description, resolution
	}
	
	override var hashValue: Int {
		return name.hashValue ^ details.hashValue ^ systemFields.hashValue ^ resolution.hashValue
	}
	
	init(name: String, description: String, resolution: Resolution) {
		let record = CKRecord(recordType: "Issue")
		self.name = name
		self.details = description
		self.resolution = resolution
		systemFields = record.archivedSystemFields()
	}
	
	required init?(record: CKRecord) {
		systemFields = record.archivedSystemFields()
		guard let name = record[CodingKeys.name.rawValue] as? String,
			let description = record[CodingKeys.description.rawValue] as? String,
			let rawResolution = record[CodingKeys.resolution.rawValue] as? Int,
			let resolution = Resolution(rawValue: rawResolution) else {
				fatalError()
		}
		self.name = name
		self.details = description
		self.resolution = resolution
	}
	
	var record: CKRecord {
		guard let result = CKRecord.unarchivedSystemFields(from: systemFields) else {
			fatalError()
		}
		
		result[CodingKeys.name.rawValue] = name as CKRecordValue
		result[CodingKeys.description.rawValue] = details as CKRecordValue
		result[CodingKeys.resolution.rawValue] = resolution.rawValue as CKRecordValue
		systemFields = result.archivedSystemFields()
		return result
	}
}


private
extension CKRecord {
	
	static func unarchivedSystemFields(from data: Data) -> CKRecord? {
		let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
		unarchiver.requiresSecureCoding = true
		return CKRecord(coder: unarchiver)
	}
	
	func archivedSystemFields() -> Data {
		let data = NSMutableData()
		let archiver = NSKeyedArchiver(forWritingWith: data)
		archiver.requiresSecureCoding = true
		encodeSystemFields(with: archiver)
		archiver.finishEncoding()
		return data as Data
	}
}
