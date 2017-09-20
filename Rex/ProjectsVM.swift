//
//  ProjectsVM.swift
//  Rex
//
//  Created by Artemiy Sobolev on 05/09/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Foundation

enum Change<T: Equatable> {
	case add(T)
	case remove(T)
	case update(T)
}

typealias ListCoordinatorHandler<Item: Equatable> = ([Item]) -> ((Change<Item>) -> Void)

protocol ListCoordinator {
	associatedtype Item: Equatable
	func update(handler: @escaping ListCoordinatorHandler<Item>) -> Progress
}

protocol ProjectListCoordinator: ListCoordinator {
	associatedtype Item = Project
}

struct CloudProjectListCoordinator: ListCoordinator {
	let context: AppContext
	
	func update(handler: @escaping ([Project]) -> ((Change<Project>) -> Void)) -> Progress {
		context.myProjects { projects in
			
			
			
		}
		return Progress()
	}
}

class ProjectsVM: NSObject {
	
	private let update: (@escaping ListCoordinatorHandler<Project>) -> Progress
	@objc dynamic var projectViewModels = Set<ProjectViewModel>()
	
	init<LCT: ListCoordinator>(projectListCoordinator plc: LCT) where LCT.Item == Project {
		update = plc.update
	}
	
	func setup(openHandler oh: @escaping (ProjectViewModel) -> Void) {
		update { [weak self] projects in
			let pvms = projects.map { ProjectViewModel(project: $0, openHandler: oh) }
			let addpvm = ProjectViewModel(projectType: .add, openHandler: oh)
			self?.projectViewModels = Set(pvms + [addpvm])
			return { [weak self] change in
				
				guard let strongSelf = self else { return }
				
				switch change {
				case .add(let p):
					let newpvm = ProjectViewModel(project: p, openHandler: oh)
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
					let newpvm = ProjectViewModel(project: p, openHandler: oh)
					strongSelf.projectViewModels.insert(newpvm)
				}
			}
		}
	}
}
