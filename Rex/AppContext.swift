//
//  Rex.swift
//  Rex
//
//  Created by Artemiy Sobolev on 10/08/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit

public class AppContext {
	
	public static let debugErrorHandler: (Error) -> Void = { error in
		debugPrint("Error happened \(error)")
	}
	
	let database: CKDatabase
	let errorHandler: (Error) -> Void
	
	public init(database: CKDatabase = CKContainer.default().publicCloudDatabase, errorHandler: @escaping (Error) -> Void = AppContext.debugErrorHandler) {
		self.database = database
		self.errorHandler = errorHandler
	}
	
	func projects(handler: @escaping ([Project]) -> Void) {
		var result = [Project]()
		let operation = CKQueryOperation(errorHandler: errorHandler) { (project: Project) in
			debugPrint("Fetched project with id \(project.recordID.recordName)")
			result.append(project)
		}
		operation.queryCompletionBlock = { [eh = errorHandler] (cursor, error) in
			if let error = error {
				eh(error)
			} else {
				handler(result)
			}
		}
		
		database.add(operation)
	}
	
	func issues(for project: Project, handler: @escaping ([Issue]) -> Void) {
		let reference = CKReference(record: project.record, action: .none)
		let predicate = NSPredicate(format: "projectID == %@", reference)
		let query = Issue.query(for: predicate)
		let op = CKQueryOperation(query: query)
		
		var result = [Issue]()
		op.recordFetchedBlock = { record in
            //  TODO: handle this error
			guard let issue = try? Issue(record: record) else {
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
	
	func remove<Value: RecordRepresentable>(_ values: [Value], completionHandler: @escaping () -> Void) {
		let idsToDelete = values.map { $0.record.recordID }
		let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: idsToDelete)
		operation.modifyRecordsCompletionBlock = { [weak self] (_, _, error) in
			if let error = error {
				self?.errorHandler(error)
			} else {
				DispatchQueue.main.async {
					completionHandler()
				}
			}
		}
		
		
		database.add(operation)
	}
	
	func remove<Value: RecordRepresentable>(_ values: Value..., completionHandler: @escaping () -> Void) {
		remove(values, completionHandler: completionHandler)
	}
	
	func save<Value: RecordRepresentable>(_ values: Value..., completionHandler: @escaping () -> Void) {
		let recordsToSave = values.map { $0.record }
		let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
		operation.modifyRecordsCompletionBlock = { [weak self] (_, _, error) in
			if let error = error {
				self?.errorHandler(error)
			}
		}
		operation.completionBlock = completionHandler
		
		database.add(operation)
	}
	
}

extension Array where Element: RecordRepresentable {
	func saveOperation() -> CKModifyRecordsOperation {
		let recordsToSave = map { $0.record }
		return CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
	}
}
