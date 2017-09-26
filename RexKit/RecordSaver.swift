//
//  RecordSaver.swift
//  Rex
//
//  Created by Artemiy Sobolev on 28/06/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit

public final class RecordSaver<ValueType: RecordRepresentable & Hashable> {
	
	public let database: CKDatabase
	
	public init(database: CKDatabase) {
		self.database = database
	}
	
	private var valueHash: Int?
	
	public var value: ValueType? {
		didSet {
			if let oldValue = oldValue, oldValue.hashValue != valueHash {
				save(record: oldValue.record)
			}
			valueHash = value?.hashValue
			debugPrint("Record saver has new value")
		}
	}
	
	private func save(record: CKRecord) {
		debugPrint("saving the record")
		database.save(record) { (record, error) in
			if let error = error {
				debugPrint("Error happened \(error)")
			} else {
				debugPrint("Saved record")
			}
		}
	}
	
	func saveIfNeeded() {
		guard let value = value, valueHash != value.hashValue else {
			return
		}
		save(record: value.record)
	}
	
	deinit {
		saveIfNeeded()
	}
}
