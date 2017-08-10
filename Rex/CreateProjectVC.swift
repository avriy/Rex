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
	private let database: CKDatabase
	init(database: CKDatabase) {
		self.database = database
	}
	
	func create(errorHandler: @escaping (Error) -> Void, successHandler: @escaping () -> Void) {
		let project = Project(name: name)
		database.save(project.record) { (record, error) in
			if let error = error {
				errorHandler(error)
			} else {
				successHandler()
			}
		}
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
		viewModel.create(errorHandler: { _ in }) { [weak self] in
			self?.view.window?.close()
		}
	}
}
