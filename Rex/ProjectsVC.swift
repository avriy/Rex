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
			DispatchQueue.main.async {
				handler(model)
			}
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
}

class ProjectsVC: NSViewController, NSCollectionViewDataSource {
	
	@objc dynamic var projects = [ProjectViewModel]()
	
	@IBOutlet weak var collectionView: NSCollectionView!
	
	func open(project: ProjectViewModel) {
		switch project.projectType {
		case .add:
			let emptyProject = Project(name: "Test")
			let operation = CKModifyRecordsOperation(recordsToSave: [emptyProject.record], recordIDsToDelete: nil)
			CKContainer.default().publicCloudDatabase.add(operation)
		case .project(let project):
			performSegue(withIdentifier: .openProject, sender: project)
		}
	}
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		guard let project = sender as? Project else {
			fatalError()
		}
		
		(segue.destinationController as? IssuesVC)?.project = project
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
			strongSelf.projects.insert(newVM, at: strongSelf.projects.count - 1)
			strongSelf.collectionView.reloadData()
	
		}
		CKContainer.default().publicCloudDatabase.add(operation)
    }
	
}
