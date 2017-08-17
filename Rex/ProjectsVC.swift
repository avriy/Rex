//
//  ProjectsVC.swift
//  Rex
//
//  Created by Artemiy Sobolev on 26/07/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa
import CloudKit

extension NSNib.Name {
	static let projectCollectionItem = NSNib.Name(rawValue: "ProjectCollectionItem")
}

extension NSUserInterfaceItemIdentifier {
	static let projectItemID = NSUserInterfaceItemIdentifier(rawValue: "ProjectCollectionItem")
}

extension NSStoryboardSegue.Identifier {
	static let openProject = NSStoryboardSegue.Identifier(rawValue: "OpenProjectSID")
	static let createProject = NSStoryboardSegue.Identifier(rawValue: "CreateProjectSID")
}

class ProjectsVC: NSViewController, NSCollectionViewDataSource {
	
	@objc dynamic var projects = [ProjectViewModel]()
	private let rex = AppContext()
	
	@IBOutlet weak var collectionView: NSCollectionView!
	
	func open(project: ProjectViewModel) {
		switch project.projectType {
		case .add:
			performSegue(withIdentifier: .createProject, sender: nil)
		case .project(let project):
			performSegue(withIdentifier: .openProject, sender: project)
		}
	}
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		guard let identifier = segue.identifier else {
			return
		}
		switch identifier {
		case .openProject:
			guard let project = sender as? Project else {
				fatalError()
			}
			
			(segue.destinationController as? IssuesVC)?.project = project
			
		case .createProject:
			(segue.destinationController as? CreateProjectVC)?.viewModel = CreateProjectViewModel(context: rex)
			
		default:
			fatalError("Undefined segue")
		}
	}
	
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return projects.count
	}
	
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		guard let result = collectionView.makeItem(withIdentifier: .projectItemID, for: indexPath) as? ProjectCollectionItem else {
			fatalError()
		}
		result.viewModel = projects[indexPath.item]
		return result
	}
	
	func fetchProjects() {
		rex.projects { [weak self] projects in
			DispatchQueue.main.async { [weak self] in
				guard let strongSelf = self else { return }
				for project in projects {
					let newVM = ProjectViewModel(projectType: .project(project), openHandler: strongSelf.open)
					
					strongSelf.projects.insert(newVM, at: strongSelf.projects.count - 1)
				}
				strongSelf.collectionView.reloadData()
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		projects = [ProjectViewModel(projectType: .add, openHandler: open)]
		collectionView.reloadData()
		
		fetchProjects()
		
		let subscription = CKQuerySubscription(recordType: "Project", predicate: NSPredicate(value: true), options: .firesOnRecordCreation)
		let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil)
		
		operation.modifySubscriptionsCompletionBlock = { (saved, deleted, error) in
			if let error = error {
				debugPrint("Failed to save subscription with error \(error)")
			}
		}
		rex.database.add(operation)
		
		NotificationCenter.default.addObserver(forName: .recordWasCreated, object: nil, queue: .main) { [unowned self] (notification) in
			debugPrint("Did receive notification from notification center")
			guard let record = notification.userInfo?["record"] as? CKRecord else {
				fatalError("Failed to create record from notification")
			}
			
			guard let project = Project(record: record) else {
				return
			}
			
			let newViewModel = ProjectViewModel(projectType: .project(project), openHandler: self.open)
			
			self.projects.insert(newViewModel, at: self.projects.count - 1)
			self.collectionView.reloadData()
		}
		
    }
	
}
