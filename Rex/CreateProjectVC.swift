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
	
	let context: AppContext
	init(context: AppContext) {
		self.context = context
	}
}

class CreateProjectVC: NSViewController, ModernView {
	@IBOutlet weak var textField: NSTextField!
	@IBOutlet weak var createButton: NSButton!
	@IBOutlet weak var projectImage: NSImageView!
	
	var viewModel: CreateProjectViewModel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		textField.bind(.value, to: viewModel, withKeyPath: #keyPath(CreateProjectViewModel.name))
		projectImage.bind(.value, to: viewModel, withKeyPath: #keyPath(CreateProjectViewModel.image))
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		apply(windowStyle: .dialog)
	}
	
	@objc func create() {
		let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("tmp")
		let project = Project(name: viewModel.name, imageURL: url)
		
		let writeImageToFile = BlockOperation { [weak self] in
			guard let imageData = self?.viewModel.image?.tiffRepresentation else { return }
			try! imageData.write(to: url)
		}
		
		let saveOperation = [project].saveOperation()
		let closeOperation = BlockOperation { [weak self] in
			self?.view.window?.close()
		}
		
		saveOperation.addDependency(writeImageToFile)
		closeOperation.addDependency(saveOperation)
		OperationQueue().addOperation(writeImageToFile)
		viewModel.context.database.add(saveOperation)
		OperationQueue.main.addOperation(closeOperation)
	}
}
