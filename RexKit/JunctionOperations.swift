//
//  JunctionOperations.swift
//  Rex
//
//  Created by Sobolev, Artemiy on 8/30/17.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit

// MARK: - `Junction` operations
extension AppContext {
    
    func inviteOperation(user: CKRecordID, to project: Project) -> CKDatabaseOperation {
		let userID = user.recordName
		let projectID = project.recordID.recordName
        let junction = Junction(userRecordID: userID, projectID: projectID)
		let record = try! cloudKitContext.record(for: junction)
        return CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
    }
    
    func acceptInvitationOperation(with junction: Junction) -> CKDatabaseOperation {
        var copy = junction
        copy.isActive = true
		let record = try! cloudKitContext.record(for: junction)
        return CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
    }
    
    private func fetchUnownedProjects(forUser recordID: CKRecordID, completion: @escaping ([Project]) -> Void) {
        debugPrint("Fetching unowned projects for user with id \(recordID.recordName)")
        
        // query `Junction` for this user
        let predicate = NSPredicate(format: "userRecordID == %@", CKReference(recordID: recordID, action: .none))
        let query = CKQuery(recordType: "Junction", predicate: predicate)
        
        let queryJunctionsOperation = CKQueryOperation(query: query)
        
        var projectIDs = [CKRecordID]()
        
        queryJunctionsOperation.recordFetchedBlock = { record in
			do {
				let junction: Junction = try self.cloudKitContext.value(from: record)
				let projectID = self.cloudKitContext.recordID(for: junction.projectID)
				projectIDs.append(projectID)
			} catch let error {
				debugPrint("Failed download with exception \(error)")
			}
        }
        
        queryJunctionsOperation.queryCompletionBlock = { [weak self, database] (cursor, error) in
            if let error = error {
                self?.errorHandler(error)
                return
            }
            
            let fetchProjectsOperation = CKFetchRecordsOperation(recordIDs: projectIDs)
            fetchProjectsOperation.fetchRecordsCompletionBlock = { (dictionary, error) in
				
				if let dictionary = dictionary {
					do {
						let projects = try dictionary.values.map(Project.init)
						DispatchQueue.main.async {
							completion(projects)
						}
						
					} catch {
						self?.errorHandler(error)
					}
				}
				
                if let error = error {
                    self?.errorHandler(error)
                    return
                }
            }
            
            database.add(fetchProjectsOperation)
            
        }
        
        database.add(queryJunctionsOperation)
        
    }
    
    public func myProjects(completion: @escaping ([Project]) -> Void) {
		
		guard let userRecordID = accountCoordinator.userRecordID else {
			fatalError("User record my be present")
		}
		fetchUnownedProjects(forUser: userRecordID, completion: completion)
    }
}
