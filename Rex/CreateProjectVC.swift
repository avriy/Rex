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
	let context: AppContext
	init(context: AppContext) {
		self.context = context
	}
}

class CreateProjectVC: NSViewController {
	@IBOutlet weak var textField: NSTextField!
	@IBOutlet weak var createButton: NSButton!
	
	var viewModel: CreateProjectViewModel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		textField.bind(.value, to: viewModel, withKeyPath: #keyPath(CreateProjectViewModel.name))
    }
	
	@objc func create() {
		let project = Project(name: viewModel.name)
		let saveOperation = [project].saveOperation()
		let closeOperation = BlockOperation { [weak self] in
			self?.view.window?.close()
		}
		closeOperation.addDependency(saveOperation)
		viewModel.context.database.add(saveOperation)
		OperationQueue.main.addOperation(closeOperation)
	}
}
