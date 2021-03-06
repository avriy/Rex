//
//  ViewController.swift
//  Rex
//
//  Created by Artemiy Sobolev on 27/06/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa
import CloudKit
import RexKit

@objc class IssuesVC: NSViewController, ModernView {
	
	@objc dynamic var project: Project?
	
	private let context = AppContext()
	
	@objc dynamic var issues = [Issue]()
	@objc dynamic var userIdentities = [CKUserIdentity]()
	@objc dynamic var sortDescriptors = [NSSortDescriptor(key: #keyPath(Issue.creationDate), ascending: false)]
	
	@IBOutlet var issuesArrayController: NSArrayController!
	
	@objc class func keyPathsForValuesAffectingSelectedIssue() -> Set<String> {
		return Set([#keyPath(selectionIndexes)])
	}
	
	@objc var selectedIssue: Issue? {
		guard selectionIndexes.count > 0 else {
			return nil
		}
		return (issuesArrayController.arrangedObjects as! [Issue])[selectionIndexes.firstIndex]
	}
	
	@objc dynamic var selectionIndexes = NSIndexSet()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		fetchIssues()

		CKContainer.default().requestPermissionsIfNeeded(errorHandler: AppContext.debugErrorHandler) { [weak self] in
			var identities = [CKUserIdentity]()
			let operation = CKDiscoverAllUserIdentitiesOperation()
			operation.qualityOfService = .userInitiated
			operation.userIdentityDiscoveredBlock = { userIdentity in
				identities.append(userIdentity)
			}
			operation.discoverAllUserIdentitiesCompletionBlock = { errorOrNil in
				
			}
			
			let updateProperties = BlockOperation { [weak self] in
				self?.userIdentities = identities
			}
			updateProperties.addDependency(operation)
			OperationQueue.main.addOperation(updateProperties)
			CKContainer.default().add(operation)
		}
	}
	
	var newIssueSelector: (() -> Void)?
	
	override func viewDidAppear() {
		super.viewDidAppear()
		apply(windowStyle: .editor)
		view.window?.title = project?.name ?? ""
		
		for vc in childViewControllers {
			if let vc = vc as? IssueDetailsVC {
				vc.bind(NSBindingName(rawValue: #keyPath(IssueDetailsVC.issue)), to: self, withKeyPath: #keyPath(selectedIssue))
				vc.viewModel.bind(NSBindingName(rawValue: #keyPath(IssueDetailsVM.project)), to: self, withKeyPath: #keyPath(project))
				vc.bind(NSBindingName(rawValue: #keyPath(IssueDetailsVC.identities)), to: self, withKeyPath: #keyPath(userIdentities))
				newIssueSelector = vc.performSelection
			}
		}
	}
	
	@IBAction func addIssueButtonPressed(_ sender: NSButton) {
		//	FIXME:
		guard let project = project else {
			fatalError("Project should be present")
		}
		let newIssue = Issue(project: project, name: "New issue", description: "", resolution: .open, priority: .low)
		issues.append(newIssue)
		selectionIndexes = NSIndexSet(index: issues.count - 1)
		newIssueSelector?()
	}
	
	@IBAction func removeButtonPressed(_ sender: NSButton) {
		guard selectionIndexes.count > 0 else {
			return
		}
		let indexToRemove = selectionIndexes.firstIndex
		context.remove(issues[indexToRemove]) { [weak self] in
			
			self?.issues.remove(at: indexToRemove)
		}
	}
	
	func fetchIssues() {
		guard let project = project else {
			fatalError("Project is not selected")
		}
		
		context.issues(for: project) { [weak self] in
			self?.issues = $0
		}
	}
}
