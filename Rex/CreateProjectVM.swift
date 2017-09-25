//
//  CreateProjectVM.swift
//  Rex
//
//  Created by Artemiy Sobolev on 03/09/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa
import CloudKit

class CreateProjectViewModel: NSObject {
	@objc dynamic var name: String = ""
	@objc dynamic var image: NSImage?
	private let creationHandler: (Project) -> Void
	private let projectSaver: ProjectSaver
	@objc dynamic var isProcessing: Bool = false
	
	func create(completion: @escaping () -> Void) -> Progress {
		isProcessing = true
		return projectSaver.saveProjectWithName(name, image: image) { [weak self] project in
			self?.isProcessing = false
			completion()
			self?.creationHandler(project)
		}
	}
	
	@objc class func keyPathsForValuesAffectingCanCreateProject() -> Set<String> {
		return Set([#keyPath(name), #keyPath(isProcessing)])
	}
	
	@objc dynamic var canCreateProject: Bool {
		return !name.isEmpty && !isProcessing
	}
	
	init(projectSaver: ProjectSaver, creationHandler: @escaping (Project) -> Void = { _ in }) {
		self.projectSaver = projectSaver; self.creationHandler = creationHandler
	}
}
