//
//  ProjectsVC.swift
//  Rex
//
//  Created by Artemiy Sobolev on 26/07/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa
import CloudKit

extension CKQueryOperation {
	convenience init<T: RecordRepresentable>(errorHandler eh: @escaping (Error) -> Void, handler: @escaping (T) -> Void) {
		let query = T.query()
		self.init(query: query)
		recordFetchedBlock = { record in
			guard let model = T(record: record) else {
				return
			}
			handler(model)
			
		}
		queryCompletionBlock = { (cursor, error) in
			if let error = error {
				eh(error)
			}
		}
	}
}

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
	private let database = CKContainer.default().publicCloudDatabase
	
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
			(segue.destinationController as? CreateProjectVC)?.viewModel = CreateProjectViewModel(database: database)
			
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
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		projects = [ProjectViewModel(projectType: .add, openHandler: open)]
		collectionView.reloadData()
		
		let operation = CKQueryOperation(errorHandler: { _ in }) { [weak self] (project: Project) in
			guard let strongSelf = self else { return }
			let newVM = ProjectViewModel(projectType: .project(project), openHandler: strongSelf.open)
			DispatchQueue.main.async { [weak self] in
				guard let strongSelf = self else { return }
				strongSelf.projects.insert(newVM, at: strongSelf.projects.count - 1)
				strongSelf.collectionView.reloadData()
			}
		}
		database.add(operation)
    }
	
}
