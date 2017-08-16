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
	private let rex = Rex()
	
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
			(segue.destinationController as? CreateProjectVC)?.viewModel = CreateProjectViewModel(rex: rex)
			
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
	
}
