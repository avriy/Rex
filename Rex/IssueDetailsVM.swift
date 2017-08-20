//
//  IssueDetailsVM.swift
//  Rex
//
//  Created by Artemiy Sobolev on 20/08/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Foundation
import CloudKit

class IssueDetailsVM: NSObject {
	
	private let recordSaver = RecordSaver<Issue>(database: CKContainer.default().publicCloudDatabase)
	@objc dynamic var project: Project!
	@objc dynamic var issue: Issue! {
		didSet {
			recordSaver.value = issue
		}
	}
	
	@objc class func keyPathsForValuesAffectingSelectedResolution() -> Set<String> {
		return Set([#keyPath(project), #keyPath(issue)])
	}
	
	@objc var selectedResolution: Int {
		get {
			guard let project = project, let issue = issue else {
				return -1
			}
			for (i, id) in project.schema.resolution.enumerated() where id.identifier == issue.resolution {
				return i
			}
			fatalError("Resolution must be present in schema")
		} set {
			issue.resolution = project.schema.resolution[newValue].identifier
		}
	}
	
	@objc class func keyPathsForValuesAffectingResolutionList() -> Set<String> {
		return Set([#keyPath(project)])
	}
	
	@objc var resolutionList: [String] {
		return project?.schema.resolution.map { $0.title.capitalized } ?? []
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
