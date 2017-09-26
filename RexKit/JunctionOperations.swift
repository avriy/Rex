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
            
            guard let junction = try? Junction(record: record) else {
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
				
				if let dictionary = dictionary {
					do {
						let projects = try dictionary.values.map(Project.init)
						completion(projects)
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
