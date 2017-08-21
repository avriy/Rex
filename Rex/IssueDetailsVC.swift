//
//  IssueDetailsVC.swift
//  Rex
//
//  Created by Artemiy Sobolev on 28/06/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa
import CloudKit

class IssueDetailsVC: NSViewController, NSComboBoxDataSource, NSComboBoxDelegate {
	
	@objc class AssigneeItem: NSObject, NSCopying {
		let identity: CKUserIdentity?
		
		init(identity: CKUserIdentity? = nil) {
			self.identity = identity
		}
		
		func copy(with zone: NSZone? = nil) -> Any {
			return AssigneeItem(identity: identity)
		}
		
		override var description: String {
			guard let identity = identity else {
				return "Not assigned"
			}
			
			guard let components = identity.nameComponents else {
				return "yo"
			}
			return (components.givenName ?? "") + " " + (components.familyName ?? "")
		}
	}
	
	private var resolutionsListObserver: NSKeyValueObservation!
	private var priorityListObserver: NSKeyValueObservation!
	
	@objc let viewModel = IssueDetailsVM()
	
	@IBOutlet weak var titleTextField: NSTextField!
	@IBOutlet weak var comboBox: NSComboBox!
	@IBOutlet weak var resolution: NSPopUpButton!
	@IBOutlet weak var priority: NSPopUpButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		viewModel.bind(NSBindingName("issue"), to: self, withKeyPath: #keyPath(issue))
		
		resolutionsListObserver = viewModel.observe(\.resolutionList, options: [.new, .initial]) { [weak self] (object, value) in
			guard let strongSelf = self else { return }
			strongSelf.resolution.removeAllItems()
			strongSelf.resolution.addItems(withTitles: object.resolutionList)
		}
		priorityListObserver = viewModel.observe(\.priorityList, options: [.new, .initial]) { [weak self] (object, value) in
			guard let strongSelf = self else { return }
			strongSelf.priority.removeAllItems()
			strongSelf.priority.addItems(withTitles: object.priorityList)
		}
		
		resolution.bind(.selectedIndex, to: viewModel, withKeyPath: #keyPath(IssueDetailsVM.selectedResolution))
		priority.bind(.selectedIndex, to: viewModel, withKeyPath: #keyPath(IssueDetailsVM.selectedPriority))
	}
	
	@objc dynamic var issue: Issue? {
		didSet {
			reloadComboBox()
		}
	}
	
	func reloadComboBox() {
		comboBox.reloadData()
		
		guard let assignee = issue?.assigneeID,
			let index = identities.index(where: { $0.userRecordID == assignee }) else {
				return comboBox.selectItem(at: 0)
		}
		comboBox.selectItem(at: index + 1)
	}
	
	@objc dynamic var identities = [CKUserIdentity]() {
		didSet {
			comboBox.reloadData()
			reloadComboBox()
		}
	}
	
	func comboBoxSelectionDidChange(_ notification: Notification) {
		switch comboBox.indexOfSelectedItem {
		case 0:
			issue?.assigneeID = nil
		default:
			issue?.assigneeID = identities[comboBox.indexOfSelectedItem - 1].userRecordID
		}
	}
	
	func numberOfItems(in comboBox: NSComboBox) -> Int {
		return identities.count + 1
	}
	
	func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
		let identity: CKUserIdentity? = index == 0 ? nil : identities[index - 1]
		return AssigneeItem(identity: identity)
	}
	
	func performSelection() {
		titleTextField.becomeFirstResponder()
	}
}
