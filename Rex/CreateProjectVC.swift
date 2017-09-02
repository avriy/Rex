//
//  CreateProjectVC.swift
//  Rex
//
//  Created by Artemiy Sobolev on 09/08/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa
import CloudKit

extension OperationQueue {
	static let io = OperationQueue()
}

class CreateProjectViewModel: NSObject {
	@objc dynamic var name: String = ""
	@objc dynamic var image: NSImage?
	private let creationHandler: (Project) -> Void
	private let context: AppContext
	
	func create(completion: @escaping () -> Void) -> Progress {
		let result = Progress()
		result.becomeCurrent(withPendingUnitCount: 0)
		
		guard let userRecordID = context.accountCoordinator.userRecordID else {
			fatalError("User should be logged in to create a project")
		}
		
		
		let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
		let project = Project(name: name, imageURL: url)
		let junction = Junction(userRecordID: userRecordID, projectID: project.recordID)
		
		let writeImageToFile = BlockOperation { [image] in
			guard let imageData = image?.tiffRepresentation else { return }
			try! imageData.write(to: url)
		}
		
		let saveOperation = CKModifyRecordsOperation(recordsToSave: [project.record, junction.record], recordIDsToDelete: nil)
		let closeOperation = BlockOperation { [handler = creationHandler] in
			handler(project)
			completion()
			result.resignCurrent()
		}
		
		let cleanupOperation = BlockOperation {
			try? FileManager.default.removeItem(at: url)
		}
		
		saveOperation.addDependency(writeImageToFile)
		closeOperation.addDependency(saveOperation)
		cleanupOperation.addDependency(closeOperation)
		
		OperationQueue.io.addOperation(writeImageToFile)
		context.database.add(saveOperation)
		OperationQueue.main.addOperation(closeOperation)
		OperationQueue.io.addOperation(cleanupOperation)
		
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

	@objc func create() {
		let progress = viewModel.create { [weak self] in
			self?.view.window?.close()
		}
		
		progressIndicator.bind(to: progress)
	}
}
