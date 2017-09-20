//
//  InvitationVM.swift
//  Rex
//
//  Created by Artemiy Sobolev on 04/09/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa

@objc
class TeamMember: NSObject {
	@objc let firstName: String
	@objc let secondName: String
	@objc let image: NSImage
	init(firstName: String, secondName: String, image: NSImage) {
		self.firstName = firstName; self.secondName = secondName; self.image = image
	}
}

protocol Invitation {
	
	func fetchMembers(handler: @escaping ([TeamMember]) -> Void) -> Progress
	func invite(members: [TeamMember], completion: @escaping () -> Void) -> Progress
	
}

class InvitationVM {
	let invitation: Invitation
	
	init(invitation: Invitation) {
		self.invitation = invitation
	}
}
