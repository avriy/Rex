//
//  User.swift
//  Rex
//
//  Created by Artemiy Sobolev on 22/08/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit

struct Junction: RecordRepresentable {
	
	let userRecordID: CKRecordID
	let projectID: CKRecordID
	var isActive: Bool
	let systemFields: Data
	
	init(userRecordID: CKRecordID, projectID: CKRecordID, isActive: Bool = false) {
		let record = CKRecord(recordType: Junction.recordType)
		self.userRecordID = userRecordID
		self.projectID = projectID
		self.isActive = isActive
		self.systemFields = record.archivedSystemFields()
	}
	
	enum CodingKeys: String {
		case user, project, isActive
	}
	
	static let recordType: String = "Junction"
	
	init?(record: CKRecord) {
		guard let urid = record[CodingKeys.user.rawValue] as? CKReference,
			let pid = record[CodingKeys.project.rawValue] as? CKReference,
			let active = record[CodingKeys.isActive.rawValue] as? Bool else {
			return nil
		}
		
		userRecordID = urid.recordID
		projectID = pid.recordID
		systemFields = record.archivedSystemFields()
		isActive = active
	}
	
	var record: CKRecord {
		guard let result = CKRecord.unarchivedSystemFields(from: systemFields) else {
			fatalError("Can not unarchave system fields")
		}
		
		result[CodingKeys.user.rawValue] = CKReference(recordID: userRecordID, action: .deleteSelf)
		result[CodingKeys.project.rawValue] = CKReference(recordID: projectID, action: .deleteSelf)
		result[CodingKeys.isActive.rawValue] = isActive as CKRecordValue
		
		return result
	}
}

// MARK: - `Junction` operations
extension AppContext {
	
	func inviteOperation(user: CKRecordID, to project: Project) -> CKDatabaseOperation {
		let junction = Junction(userRecordID: user, projectID: project.recordID)
		return [junction].saveOperation()
	}
	
	func acceptInvitationOperation(with junction: Junction) -> CKDatabaseOperation {
		var copy = junction
		copy.isActive = true
		return [junction].saveOperation()
	}
	
	private func fetchUnownedProjects(forUser recordID: CKRecordID, completion: @escaping ([Project]) -> Void) {
		debugPrint("Fetching unowned projects for user with id \(recordID.recordName)")
		
		// query `Junction` for this user
		let predicate = NSPredicate(format: "user == %@", CKReference(recordID: recordID, action: .none))
		let query = Junction.query(for: predicate)
		
		let queryJunctionsOperation = CKQueryOperation(query: query)
		
		var projectIDs = [CKRecordID]()
		
		queryJunctionsOperation.recordFetchedBlock = { record in
			
			guard let junction = Junction(record: record) else {
				fatalError()
			}
			
			projectIDs.append(junction.projectID)
		}
		
		queryJunctionsOperation.queryCompletionBlock = { [weak self, database] (cursor, error) in
			if let error = error {
				self?.errorHandler(error)
				return
			}
			
			let fetchProjectsOperation = CKFetchRecordsOperation(recordIDs: projectIDs)
			fetchProjectsOperation.fetchRecordsCompletionBlock = { (dictionary, error) in
				if let error = error {
					self?.errorHandler(error)
					return
				}
				
				guard let projects = dictionary?.values.flatMap(Project.init) else {
					fatalError()
				}
				
				completion(projects)
				
			}
			
			database.add(fetchProjectsOperation)
			
		}
		
		database.add(queryJunctionsOperation)

	}
	
	func myProjects(completion: @escaping ([Project]) -> Void) {
		
		CKContainer.default().fetchUserRecordID { [weak self] (recordID, error) in

			if let error = error {
				self?.errorHandler(error)
				return
			}
			
			guard let recordID = recordID else {
				fatalError()
			}
			
			self?.fetchUnownedProjects(forUser: recordID, completion: completion)
		}
	}
}
