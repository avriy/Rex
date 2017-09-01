//
//  StoryboardIDs.swift
//  Rex
//
//  Created by Artemiy Sobolev on 01/09/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa

extension NSNib.Name {
	static let projectCollectionItem = NSNib.Name(rawValue: "ProjectCollectionItem")
}

extension NSUserInterfaceItemIdentifier {
	static let projectItemID = NSUserInterfaceItemIdentifier(rawValue: "ProjectCollectionItem")
}

extension NSStoryboardSegue.Identifier {
	static let openProject = NSStoryboardSegue.Identifier(rawValue: "OpenProjectSID")
	static let createProject = NSStoryboardSegue.Identifier(rawValue: "CreateProjectSID")
	
	static let openProjectList = NSStoryboardSegue.Identifier(rawValue: "OpenProjectsList")
}
