//
//  ViewController.swift
//  Rex
//
//  Created by Artemiy Sobolev on 27/06/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa
import CloudKit

let defaultErrorHandler: (Error) -> Void = { error in
	debugPrint("Error happened \(error)")
}

final class IssuesVC: NSViewController {
	
	private let database = CKContainer.default().publicCloudDatabase
	
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
		
		CKContainer.default().requestPermissionsIfNeeded(errorHandler: defaultErrorHandler) { [weak self] in
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
		for vc in childViewControllers {
			if let vc = vc as? IssueDetailsVC {
				vc.bind(NSBindingName(rawValue: #keyPath(IssueDetailsVC.issue)), to: self, withKeyPath: #keyPath(selectedIssue))
				vc.bind(NSBindingName(rawValue: #keyPath(IssueDetailsVC.identities)), to: self, withKeyPath: #keyPath(userIdentities))
				newIssueSelector = vc.performSelection
			}
		}
	}
	
	@IBAction func addIssueButtonPressed(_ sender: NSButton) {
		let newIssue = Issue(name: "New issue", description: "", resolution: .open)
		issues.append(newIssue)
		selectionIndexes = NSIndexSet(index: issues.count - 1)
		newIssueSelector?()
	}
	
	@IBAction func removeButtonPressed(_ sender: NSButton) {
		guard selectionIndexes.count > 0 else {
			return
		}
		let issue = issues.remove(at: selectionIndexes.firstIndex)
		let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [issue.record.recordID])
		database.add(operation)
	}
	
	func fetchIssues() {
		let query = CKQuery(recordType: "Issue", predicate: NSPredicate(value: true))
		let op = CKQueryOperation(query: query)
		op.recordFetchedBlock = { [weak self] record in
			
			guard let issue = Issue(record: record) else {
				return
			}
			
			DispatchQueue.main.async { [weak self] in
				self?.issues.append(issue)
			}
		}
		
		database.add(op)
	}
}
