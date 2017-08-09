//
//  ProjectCollectionItem.swift
//  Rex
//
//  Created by Artemiy Sobolev on 27/07/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa

@objc class ProjectViewModel: NSObject {
	enum ProjectType {
		case project(Project)
		case add
	}
	
	let projectType: ProjectType
	let openHandler: (ProjectViewModel) -> Void
	
	init(projectType: ProjectType, openHandler: @escaping (ProjectViewModel) -> Void) {
		self.projectType = projectType
		self.openHandler = openHandler
	}
	
	@objc var title: String {
		switch projectType {
		case .add:
			return "New project"
		case .project(let project):
			return project.name
		}
	}
	
	@objc var image: NSImage {
		return NSImage(named: NSImage.Name.addTemplate)!
	}

	func open() {
		openHandler(self)
	}	
}

class ProjectCollectionItem: NSCollectionViewItem {
	@objc dynamic var viewModel: ProjectViewModel?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		textField?.bind(.value, to: self, withKeyPath: #keyPath(viewModel.title))
	}
	
	override func mouseUp(with event: NSEvent) {
		guard let viewModel = viewModel else { return }
		viewModel.openHandler(viewModel)
	}
	
}