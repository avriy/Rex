//
//  ProjectCollectionItem.swift
//  Rex
//
//  Created by Artemiy Sobolev on 27/07/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa
import RexKit

@objc protocol ProjectViewModelOpenDelegate: class {
	func openProject(with viewModel: ProjectViewModel)
}

@objc class ProjectViewModel: NSObject {
	enum ProjectType {
		case project(Project)
		case add
	}
	
	let projectType: ProjectType
	weak var delegate: ProjectViewModelOpenDelegate?
	
	init(project: Project) {
		self.projectType = .project(project)
	}
	
	private init(projectType: ProjectType) {
		self.projectType = projectType
	}
	
	static var add: ProjectViewModel {
		return ProjectViewModel(projectType: .add)
	}
	
	@objc var title: String {
		switch projectType {
		case .add:
			return "New project"
		case .project(let project):
			return project.name
		}
	}
	
	@objc var project: Project? {
		switch projectType {
		case .add: return nil
		case .project(let p): return p
		}
	}
	
	@objc var image: NSImage? {
		switch projectType {
		case .add:
			return NSImage(named: NSImage.Name.addTemplate)
		case .project(let project):
			guard let imageURL = project.imageURL else {
				return nil
			}
			return NSImage(byReferencing: imageURL)
		}
	}

	func open() {
		delegate?.openProject(with: self)
	}	
}

class ProjectCollectionItem: NSCollectionViewItem {

	private var labelObservation: NSKeyValueObservation!
	
	@objc dynamic var viewModel: ProjectViewModel?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		labelObservation = observe(\.viewModel, options: [.new, .initial]) { [unowned self] (object, value) in
			guard let viewModel = self.viewModel else { return }
			self.textField?.stringValue = viewModel.title
			let textFieldAccessibility = viewModel.title
			self.textField?.setAccessibilityIdentifier(textFieldAccessibility)
			return
		}
		
		imageView?.bind(.value, to: self, withKeyPath: #keyPath(viewModel.image))
	}
	
	override func mouseUp(with event: NSEvent) {
		guard let viewModel = viewModel else { return }
		viewModel.open()
	}
}
