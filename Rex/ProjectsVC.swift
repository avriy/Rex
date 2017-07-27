//
//  ProjectsVC.swift
//  Rex
//
//  Created by Artemiy Sobolev on 26/07/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa
import CloudKit

extension CKQueryOperation {
	convenience init<T: RecordRepresentable>(errorHandler eh: @escaping (Error) -> Void, handler: @escaping (T) -> Void) {
		let query = T.query()
		self.init(query: query)
		recordFetchedBlock = { record in
			guard let model = T(record: record) else {
				return
			}
			DispatchQueue.main.async {
				handler(model)
			}
		}
		queryCompletionBlock = { (cursor, error) in
			if let error = error {
				eh(error)
			}
		}
	}
}

class ProjectsVC: NSViewController {
	
	@objc dynamic var projects = [Project]()
	@IBOutlet var projectsArrayController: NSArrayController!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		projectsArrayController.bind(.contentArray, to: self, withKeyPath: #keyPath(projects))
		
		let operation = CKQueryOperation(errorHandler: { _ in }) { [weak self] (project: Project) in
			self?.projects.append(project)
		}
		CKContainer.default().publicCloudDatabase.add(operation)
    }
	
	@IBAction func createProjectButtonPressed(_ sender: NSButton) {
		let emptyProject = Project(name: "Test")
		let operation = CKModifyRecordsOperation(recordsToSave: [emptyProject.record], recordIDsToDelete: nil)
		CKContainer.default().publicCloudDatabase.add(operation)
	}
	
}
