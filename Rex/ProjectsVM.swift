//
//  ProjectsVM.swift
//  Rex
//
//  Created by Artemiy Sobolev on 05/09/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Foundation
import RexKit

class ProjectsVM: NSObject {
	
	private let update: (@escaping ListCoordinatorHandler<Project>) -> Progress
	@objc dynamic var projectViewModels = Set<ProjectViewModel>()
	@objc dynamic var arrayController = NSArrayController()
	
	init<LCT: ListCoordinator>(projectListCoordinator plc: LCT) where LCT.Item == Project {
		update = plc.update
		super.init()
		arrayController.sortDescriptors = [ProjectsVM.projectsSortDescriptor]
		arrayController.bind(.contentSet, to: self, withKeyPath: #keyPath(projectViewModels))
	}
	
	private static var projectsSortDescriptor: NSSortDescriptor {
		return NSSortDescriptor(keyPath: \ProjectViewModel.project, ascending: false) { obj1, obj2 in
			let prj1 = obj1 as! Project
			let prj2 = obj2 as! Project
			return prj2.name.compare(prj1.name)
		}
	}
	
	func add(project: Project) {
		let viewModel = ProjectViewModel(project: project)
		projectViewModels.insert(viewModel)
	}
	
	func fetch() {
        //  TODO: handle progress reporting here
		_ = update { [weak self] projects in
			let pvms = projects.map(ProjectViewModel.init(project:))
			let addpvm = ProjectViewModel.add
			self?.projectViewModels = Set(pvms + [addpvm])
			return { [weak self] change in
				
				guard let strongSelf = self else { return }
				
				switch change {
				case .add(let p):
					let newpvm = ProjectViewModel(project: p)
					strongSelf.projectViewModels.insert(newpvm)
				case .remove(let p):
					guard let firstMatching = strongSelf.projectViewModels.index(where: { $0.project == p }) else {
						return
					}
					strongSelf.projectViewModels.remove(at: firstMatching)
				case .update(let p):
					guard let firstMatching = strongSelf.projectViewModels.index(where: { $0.project == p }) else {
						return
					}
					strongSelf.projectViewModels.remove(at: firstMatching)
					let newpvm = ProjectViewModel(project: p)
					strongSelf.projectViewModels.insert(newpvm)
				}
			}
		}
	}
}
