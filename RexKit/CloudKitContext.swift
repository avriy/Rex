//
//  CloudKitContext.swift
//  RexKit
//
//  Created by Artemiy Sobolev on 08/10/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit

protocol Identifiable {
	associatedtype Identifier: Hashable
	var id: Identifier { get }
}

protocol MetadataStore {
	associatedtype Identifier: Hashable
	
	func save(data: Data, forKey: Identifier)
	func getData(for key: Identifier) -> Data?
	
	func recordID(for identifier: Identifier) -> CKRecordID
	func identifier(for recordID: CKRecordID) -> Identifier
}

struct TransformationException {
	let type: String
	let key: String
	let tranformation: (CKRecordValue) -> Any
}

final
class CloudKitContext<MetadataStoreType: MetadataStore> {
	
	private let queue = DispatchQueue(label: "CloudKitContext queue", attributes: .concurrent)
	
	private var metadataStore: MetadataStoreType
	
	init(metadataStore: MetadataStoreType) {
		self.metadataStore = metadataStore
	}
	
	func recordID(for identifier: MetadataStoreType.Identifier) -> CKRecordID {
		return metadataStore.recordID(for: identifier)
	}
	
	func identifier(for recordID: CKRecordID) -> MetadataStoreType.Identifier {
		return metadataStore.identifier(for: recordID)
	}
	
	private func fill<ValueType: Codable & Identifiable>(record: CKRecord, with value: ValueType) throws {
		let jsonEncoder = JSONEncoder()
		let data = try jsonEncoder.encode(value)
		let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable : Any]
		
		for (key, value) in dictionary {
			guard let key = key as? String, key != "id" else {
				continue
			}
			
			if let otherIdentifier = value as? MetadataStoreType.Identifier {
				let otherRecordID = metadataStore.recordID(for: otherIdentifier)
				record[key] = CKReference(recordID: otherRecordID, action: .none)
				continue
			}
			
			guard let value = value as? CKRecordValue else {
				continue
			}
			record[key] = value
		}
	}
	
	func value<ValueType: Codable & Identifiable>(from record: CKRecord) throws -> ValueType
		where ValueType.Identifier == MetadataStoreType.Identifier {
		let decoder = JSONDecoder()
		var jsonObject = [String : Any]()
		for key in record.allKeys() {
			if let reference = record.object(forKey: key) as? CKReference {
				jsonObject[key] = metadataStore.identifier(for: reference.recordID)
			} else {
				jsonObject[key] = record.object(forKey: key)
			}
		}
		jsonObject["id"] = metadataStore.identifier(for: record.recordID)
			// FIXME: use transformationExceptions
		if let isActive = jsonObject["isActive"] as? Int {
			jsonObject["isActive"] = isActive == 1
		}
		
		let data = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
		let result = try decoder.decode(ValueType.self, from: data)
			
		queue.async(flags: .barrier) {
			self.metadataStore.save(data: record.archivedSystemFields(), forKey: result.id)
		}
		
		return result
	}
	
	func record<ValueType: Codable & Identifiable>(for value: ValueType) throws -> CKRecord
		where ValueType.Identifier == MetadataStoreType.Identifier {
		var recordData: Data?
		
		queue.sync {
			recordData = metadataStore.getData(for: value.id)
		}
		
		if let data = recordData, let record = CKRecord.unarchivedSystemFields(from: data) {
			try fill(record: record, with: value)
			return record
		} else {
			let recordID = metadataStore.recordID(for: value.id)
			let recordType = "\(type(of: value))"
			let record = CKRecord(recordType: recordType, recordID: recordID)
			try fill(record: record, with: value)
			return record
		}
	}
}
