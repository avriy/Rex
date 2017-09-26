//
//  Rex.swift
//  Rex
//
//  Created by Artemiy Sobolev on 10/08/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit

public class AppContext: NSObject {

    public static let debugErrorHandler: (Error) -> Void = { error in
		debugPrint("Error happened \(error)")
	}
	
	let database: CKDatabase
    let container: CKContainer
	let errorHandler: (Error) -> Void
	
    public let accountCoordinator: CloudAccountCoordinator<CloudKitUserRecordFetcher>
    
    public init(container: CKContainer = .default(), databaseScope: CKDatabaseScope = .public, errorHandler: @escaping (Error) -> Void = AppContext.debugErrorHandler) {
		self.container = container
        self.database = container.database(with: databaseScope)
		self.errorHandler = errorHandler
        let fetcher = CloudKitUserRecordFetcher(container: container)
        accountCoordinator = CloudAccountCoordinator(store: UserDefaults.standard, fetcher: fetcher)
	}
	
	public func projects(handler: @escaping ([Project]) -> Void) {
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
	
	public func issues(for project: Project, handler: @escaping ([Issue]) -> Void) {
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
	
	public func remove<Value: RecordRepresentable>(_ values: [Value], completionHandler: @escaping () -> Void) {
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
	
	public func remove<Value: RecordRepresentable>(_ values: Value..., completionHandler: @escaping () -> Void) {
		remove(values, completionHandler: completionHandler)
	}
	
	public func save<Value: RecordRepresentable>(_ values: Value..., completionHandler: @escaping () -> Void) {
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

public
extension Array where Element: RecordRepresentable {
	func saveOperation() -> CKModifyRecordsOperation {
		let recordsToSave = map { $0.record }
		return CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
	}
}
