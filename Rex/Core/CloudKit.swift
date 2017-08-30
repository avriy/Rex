//
//  CloudKit.swift
//  Rex
//
//  Created by Artemiy Sobolev on 28/06/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit

extension CKContainer {
	func requestPermissionsIfNeeded(errorHandler eh: @escaping (Error) -> Void, successHandler sh: @escaping () -> Void) {
		
		accountStatus { [weak self] (status, error) in
			if let error = error {
				return eh(error)
			}
			
			guard status != .available else {
				return sh()
			}
			
			self?.requestApplicationPermission(.userDiscoverability) { (status, error) in
				if let error = error {
					return eh(error)
				}
				sh()
			}
		}
	}
}

extension CKQueryOperation {
	convenience init<T: RecordRepresentable>(errorHandler eh: @escaping (Error) -> Void, handler: @escaping (T) -> Void) {
		let query = T.query()
		self.init(query: query)
		recordFetchedBlock = { record in
			guard let model = try? T(record: record) else {
				return
			}
			handler(model)
			
		}
		queryCompletionBlock = { (cursor, error) in
			if let error = error {
				eh(error)
			}
		}
	}
}

protocol RecordRepresentable {
	init(record: CKRecord) throws
	var record: CKRecord { get }
	static var recordType: String { get }
}

extension RecordRepresentable {
	static func query(for predicate: NSPredicate = NSPredicate(value: true)) -> CKQuery {
		return CKQuery(recordType: recordType, predicate: predicate)
	}
}

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

