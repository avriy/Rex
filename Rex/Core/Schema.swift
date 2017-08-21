//
//  Schema.swift
//  Rex
//
//  Created by Artemiy Sobolev on 21/08/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Foundation

struct Schema: Codable {
	
	struct Priority: Codable, Equatable, IdentifiedTitle {
		typealias Identifier = Int
		
		let identifier: Identifier
		let title: String
		
		static func == (lhs: Priority, rhs: Priority) -> Bool {
			return lhs.identifier == rhs.identifier && lhs.title == rhs.title
		}
		
		static let low = Priority(identifier: 0, title: "low")
		static let medium = Priority(identifier: 1, title: "medium")
		static let high = Priority(identifier: 2, title: "high")
	}
	
	struct Resolution: Codable, Equatable, IdentifiedTitle {
		typealias Identifier = Int
		
		let identifier: Identifier
		let title: String
		
		static func == (lhs: Resolution, rhs: Resolution) -> Bool {
			return lhs.identifier == rhs.identifier && lhs.title == rhs.title
		}
		
		static let open = Resolution(identifier: 0, title: "open")
		static let resolved = Resolution(identifier: 1, title: "resolved")
		static let reopened = Resolution(identifier: 2, title: "reopened")
	}
	
	var priorities: [Priority]
	var resolutions: [Resolution]
	var defaultPriority: Priority
	var defaultResolution: Resolution
	
	static let start = Schema(priorities: [.low, .medium, .high],
							  resolutions: [.open, .resolved, .reopened],
							  defaultPriority: .medium,
							  defaultResolution: .open)
	
	enum MigrationError: Error {
		case invalidSchema
		case emptySchema
	}
	
	func resolution(for issue: Issue) -> Resolution? {
		return resolutions.first { $0.identifier == issue.resolutionID }
	}
}

protocol IdentifiedTitle {
	associatedtype Identifier: Equatable
	var identifier: Identifier { get }
	var title: String { get }
}

extension Array where Element: IdentifiedTitle {
	var titles: [String] {
		return map { $0.title }
	}
	
	func selectedIndex(of identifier: Element.Identifier) -> Int? {
		for (i, id) in enumerated() where id.identifier == identifier {
			return i
		}
		return nil
	}
}
