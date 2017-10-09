//
//  ProjectVC.swift
//  Rex
//
//  Created by Artemiy Sobolev on 08/10/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa

final class ProjectVC: NSViewController {
	
	@IBOutlet weak var titleTextField: NSTextField!
	@IBOutlet weak var inviteButton: NSButton!
	
	@objc dynamic var viewModel: ProjectVM!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		titleTextField.bind(.value, to: viewModel, withKeyPath: #keyPath(ProjectVM.project.name))
		
	}
	
}
