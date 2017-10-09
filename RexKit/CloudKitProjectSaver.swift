//
//  CloudKitProjectSaver.swift
//  Rex
//
//  Created by Artemiy Sobolev on 04/09/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit
import Cocoa

public
struct CloudKitProjectSaver: ProjectSaver {
	let context: AppContext
    
    public init(context: AppContext) {
        self.context = context
    }
	
	private static func newTemporaryURL() -> URL {
		return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
	}
	
    public func saveProjectWithName(_ name: String, image: NSImage?, completion: @escaping (Project) -> Void) -> Progress {
		let result = Progress()
		result.becomeCurrent(withPendingUnitCount: 0)
		
		guard let userRecordID = context.accountCoordinator.userRecordID else {
			fatalError("User should be logged in to create a project")
		}
		
		let url = image == nil ? nil : CloudKitProjectSaver.newTemporaryURL()
		let project = Project(name: name, imageURL: url)
		
		let uid = userRecordID.recordName
		let projectID = project.recordID.recordName
		let junction = Junction(userRecordID: uid, projectID: projectID)
		
		let writeImageToFile = BlockOperation { [image] in
			guard let imageData = image?.tiffRepresentation, let url = url else { return }
			try! imageData.write(to: url)
		}
		
		let junctionRecord = try! context.cloudKitContext.record(for: junction)
		let saveOperation = CKModifyRecordsOperation(recordsToSave: [project.record, junctionRecord], recordIDsToDelete: nil)
		
		saveOperation.modifyRecordsCompletionBlock = { [eh = context.errorHandler] (_, _, error) in
			if let error = error {
				eh(error)
			}
		}
		
		let closeOperation = BlockOperation {
			completion(project)
			result.resignCurrent()
		}
		
		saveOperation.addDependency(writeImageToFile)
		closeOperation.addDependency(saveOperation)
		
		OperationQueue.io.addOperation(writeImageToFile)
		context.database.add(saveOperation)
		OperationQueue.main.addOperation(closeOperation)
		
		return result
	}
}

