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
	
	let recordSaver = RecordSaver<Issue>(database: CKContainer.default().publicCloudDatabase)
	
	@IBOutlet weak var titleTextField: NSTextField!
	@IBOutlet weak var comboBox: NSComboBox!
	
	@objc dynamic var issue: Issue? {
		didSet {
			recordSaver.value = issue
			reloadComboBox()
		}
	}
	
	func reloadComboBox() {
		comboBox.reloadData()
		
		guard let assignee = issue?.assignee,
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
			issue?.assignee = nil
		default:
			issue?.assignee = identities[comboBox.indexOfSelectedItem - 1].userRecordID
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
	
	@objc class func keyPathsForValuesAffectingDetails() -> Set<String> {
		return Set([#keyPath(issue.details)])
	}
	
	@objc var details: NSAttributedString? {
		get {
			guard let value = issue?.details else {
				return nil
			}
			return NSAttributedString(string: value)
		} set {
			guard let string = newValue?.string else {
				issue?.details = ""
				return
			}
			issue?.details = string
		}
	}
}
