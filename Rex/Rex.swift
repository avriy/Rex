//
//  Rex.swift
//  Rex
//
//  Created by Artemiy Sobolev on 10/08/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit

class Rex {
	
	static let debugErrorHandler: (Error) -> Void = { error in
		debugPrint("Error happened \(error)")
	}
	
	let database: CKDatabase
	let errorHandler: (Error) -> Void
	
	init(database: CKDatabase = CKContainer.default().publicCloudDatabase, errorHandler: @escaping (Error) -> Void = Rex.debugErrorHandler) {
		self.database = database
		self.errorHandler = errorHandler
	}
	
	func issues(for project: Project, handler: @escaping ([Issue]) -> Void) {
		let reference = CKReference(record: project.record, action: .none)
		let predicate = NSPredicate(format: "projectID == %@", reference)
		let query = Issue.query(for: predicate)
		let op = CKQueryOperation(query: query)
		
		var result = [Issue]()
		op.recordFetchedBlock = { record in
			guard let issue = Issue(record: record) else {
				return
			}
			
			result.append(issue)
		}
		op.queryCompletionBlock = { [weak self] (cursor, error) in
			if let error = error {
				self?.errorHandler(error)
			}
			DispatchQueue.main.async {
				handler(result)
			}
		}
		
		database.add(op)
	}
	
	func remove<Value: RecordRepresentable>(_ value: Value, completionHandler: @escaping () -> Void) {
		let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [value.record.recordID])
		operation.modifyRecordsCompletionBlock = { [weak self] (_, _, error) in
			if let error = error {
				self?.errorHandler(error)
			} else {
				completionHandler()
			}
		}
		database.add(operation)
	}
	
}

