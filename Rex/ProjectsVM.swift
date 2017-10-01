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
	
	init<LCT: ListCoordinator>(projectListCoordinator plc: LCT) where LCT.Item == Project {
		update = plc.update
	}
	
	func setup(openHandler oh: @escaping (ProjectViewModel) -> Void) {
        //  TODO: handle progress reporting here
		_ = update { [weak self] projects in
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
	
	//    func setupSubscription() {
	//        let subscription = CKQuerySubscription(recordType: "Project", predicate: NSPredicate(value: true), options: .firesOnRecordCreation)
	//        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil)
	//
	//        operation.modifySubscriptionsCompletionBlock = { (saved, deleted, error) in
	//            if let error = error {
	//                debugPrint("Failed to save subscription with error \(error)")
	//            }
	//        }
	//        context.database.add(operation)
	//
	//        NotificationCenter.default.addObserver(forName: .recordWasCreated, object: nil, queue: .main) { [unowned self] (notification) in
	//            debugPrint("Did receive notification from notification center")
	//            guard let record = notification.userInfo?["record"] as? CKRecord else {
	//                fatalError("Failed to create record from notification")
	//            }
	//
	//            guard let project = try? Project(record: record) else {
	//                return
	//            }
	//
	//            let newViewModel = ProjectViewModel(projectType: .project(project), openHandler: self.open)
	//
	//            self.projects.insert(newViewModel, at: self.projects.count - 1)
	//            self.collectionView.reloadData()
	//        }
	//    }
}
