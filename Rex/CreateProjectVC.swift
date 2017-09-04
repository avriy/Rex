//
//  CreateProjectVC.swift
//  Rex
//
//  Created by Artemiy Sobolev on 09/08/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa

extension OperationQueue {
	static let io = OperationQueue()
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
		
		textField.bind(.enabled, to: self, withKeyPath: #keyPath(viewModel.isProcessing),
		               options: [.valueTransformerName : NSValueTransformerName.negateBooleanTransformerName])
		
		createButton.bind(.enabled, to: self, withKeyPath: #keyPath(viewModel.canCreateProject))

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
