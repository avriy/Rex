//
//  ProjectsVC.swift
//  Rex
//
//  Created by Artemiy Sobolev on 26/07/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa
import RexKit

class ProjectsVC: NSViewController, NSCollectionViewDataSource, ModernView, ContextDepending, ProjectViewModelOpenDelegate {
	
	@objc dynamic lazy var viewModel = ProjectsVM(projectListCoordinator: CloudProjectListCoordinator(context: self.context))
	
	@IBOutlet weak var collectionView: NSCollectionView!
	
	func openProject(with viewModel: ProjectViewModel) {
		switch viewModel.projectType {
		case .add:
			performSegue(withIdentifier: .createProject, sender: nil)
		case .project(let project):
			performSegue(withIdentifier: .openProject, sender: project)
		}
	}
	
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewModel.projectViewModels.count
	}
	
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		guard let result = collectionView.makeItem(withIdentifier: .projectItemID, for: indexPath) as? ProjectCollectionItem else {
			fatalError()
		}
		result.viewModel = (viewModel.arrayController.arrangedObjects as! [ProjectViewModel])[indexPath.item]
		result.viewModel?.delegate = self
		return result
	}
	
	func fetchProjects() {
		viewModel.fetch()
	}
	
	private var objectsOpservation: NSKeyValueObservation!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		objectsOpservation = viewModel.arrayController.observe(\.arrangedObjects) { [unowned self] (object, change) in
			self.collectionView.reloadData()
		}
		
		fetchProjects()
		
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		
		apply(windowStyle: .dialog, adding: [.resizable, .miniaturizable])
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
			let cloudProjectSaver = CloudKitProjectSaver(context: context)
			let createProjectViewModel = CreateProjectViewModel(projectSaver: cloudProjectSaver, creationHandler: viewModel.add)
			(segue.destinationController as? CreateProjectVC)?.viewModel = createProjectViewModel
			
		default:
			fatalError("Undefined segue")
		}
	}
}
