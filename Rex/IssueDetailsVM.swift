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
			
			guard let index = project.schema.resolutions.selectedIndex(of: issue.resolutionID) else {
				fatalError("Resolution must be present in schema")
			}
			return index
		} set {
			issue.resolutionID = project.schema.resolutions[newValue].identifier
		}
	}
	
	@objc class func keyPathsForValuesAffectingResolutionList() -> Set<String> {
		return Set([#keyPath(project)])
	}
	
	@objc var resolutionList: [String] {
		return project?.schema.resolutions.map { $0.title.capitalized } ?? []
	}
	
	@objc class func keyPathsForValuesAffectingSelectedPriority() -> Set<String> {
		return Set([#keyPath(project), #keyPath(issue)])
	}
	
	@objc var selectedPriority: Int {
		get {
			guard let project = project, let issue = issue else {
				return -1
			}
			
			guard let index = project.schema.priorities.selectedIndex(of: issue.priorityID) else {
				fatalError("Resolution must be present in schema")
			}
			return index
		} set {
			issue.priorityID = project.schema.priorities[newValue].identifier
		}
	}
	
	@objc class func keyPathsForValuesAffectingPriorityList() -> Set<String> {
		return Set([#keyPath(project)])
	}
	
	@objc var priorityList: [String] {
		return project?.schema.priorities.map { $0.title.capitalized } ?? []
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
