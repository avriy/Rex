//
//  User.swift
//  Rex
//
//  Created by Artemiy Sobolev on 22/08/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Foundation

struct Junction: Codable, Identifiable {
	let id: String
	let userRecordID: String
	let projectID: String
	
	var isActive: Bool
	
	init(userRecordID: String, projectID: String, isActive: Bool = true) {
		self.userRecordID = userRecordID
		self.projectID = projectID
		self.isActive = isActive
		self.id = UUID().uuidString
	}
}
