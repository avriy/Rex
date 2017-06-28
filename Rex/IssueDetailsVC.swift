//
//  IssueDetailsVC.swift
//  Rex
//
//  Created by Artemiy Sobolev on 28/06/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa
import CloudKit

class IssueDetailsVC: NSViewController {
	
	let recordSaver = RecordSaver<Issue>(database: CKContainer.default().publicCloudDatabase)
	
	@IBOutlet weak var titleTextField: NSTextField!
	
	@objc dynamic var issue: Issue? {
		didSet {
			recordSaver.value = issue
		}
	}
	
	func performSelection() {
		titleTextField.becomeFirstResponder()
	}
	
	@objc class func keyPathsForValuesAffectingDetails() -> Set<String> {
		return Set(["issue.details"])
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
