//
//  CreateProjectVC.swift
//  Rex
//
//  Created by Artemiy Sobolev on 09/08/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa
import CloudKit

class CreateProjectViewModel: NSObject {
	@objc dynamic var name: String = ""
	@objc dynamic var image: NSImage?
	let creationHandler: (Project) -> Void
	let context: AppContext
	
	func create(completion: (Void)) -> Progress {
		let result = Progress()
		
		guard let userRecordID = context.accountCoordinator.userRecordID else {
			fatalError("User should be logged in to create a project")
		}
	
		let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("tmp")
		let project = Project(name: name, imageURL: url)
		let junction = Junction(userRecordID: userRecordID, projectID: project.recordID)
		
		let writeImageToFile = BlockOperation { [image] in
			guard let imageData = image?.tiffRepresentation else { return }
			try! imageData.write(to: url)
		}
		
		let saveOperation = CKModifyRecordsOperation(recordsToSave: [project.record, junction.record], recordIDsToDelete: nil)
		let closeOperation = BlockOperation { [handler = creationHandler] in
			handler(project)
		}
		
		saveOperation.addDependency(writeImageToFile)
		closeOperation.addDependency(saveOperation)
		OperationQueue().addOperation(writeImageToFile)
		context.database.add(saveOperation)
		OperationQueue.main.addOperation(closeOperation)
		
		return result
	}
	
	init(context: AppContext, creationHandler: @escaping (Project) -> Void) {
		self.context = context; self.creationHandler = creationHandler
	}
}

class CreateProjectVC: NSViewController, ModernView {
	@IBOutlet weak var textField: NSTextField!
	@IBOutlet weak var createButton: NSButton!
	@IBOutlet weak var projectImage: NSImageView!
	@IBOutlet weak var progressIndicator: NSProgressIndicator!
	
	@objc dynamic var viewModel: CreateProjectViewModel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		textField.bind(.value, to: self, withKeyPath: #keyPath(viewModel.name),
		               options: [.continuouslyUpdatesValue : true, .nullPlaceholder : "New project name"])
		projectImage.bind(.value, to: self, withKeyPath: #keyPath(viewModel.image))
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		apply(windowStyle: .dialog)
	}
	
	private func create(forUser recordID: CKRecordID) {
		let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("tmp")
		let project = Project(name: viewModel.name, imageURL: url)
		let junction = Junction(userRecordID: recordID, projectID: project.recordID)
		
		let writeImageToFile = BlockOperation { [weak self] in
			guard let imageData = self?.viewModel.image?.tiffRepresentation else { return }
			try! imageData.write(to: url)
		}
		
		let saveOperation = CKModifyRecordsOperation(recordsToSave: [project.record, junction.record], recordIDsToDelete: nil)
		let closeOperation = BlockOperation { [weak self] in
			self?.view.window?.close()
			self?.viewModel.creationHandler(project)
		}
		
		saveOperation.addDependency(writeImageToFile)
		closeOperation.addDependency(saveOperation)
		OperationQueue().addOperation(writeImageToFile)
		viewModel.context.database.add(saveOperation)
		OperationQueue.main.addOperation(closeOperation)
	}
	
	@objc func create() {
//		let progress = viewModel.create()
//		progressIndicator.bind(<#T##binding: NSBindingName##NSBindingName#>, to: <#T##Any#>, withKeyPath: <#T##String#>, options: <#T##[NSBindingOption : Any]?#>)
		
		CKContainer.default().fetchUserRecordID { [weak self] (recordID, error) in
			if let recordID = recordID {
				self?.create(forUser: recordID)
			}
			if let error = error {
				fatalError("Failed with error \(error)")
			}
		}
	}
}
