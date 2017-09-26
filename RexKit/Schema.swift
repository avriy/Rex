//
//  Schema.swift
//  Rex
//
//  Created by Artemiy Sobolev on 21/08/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

public struct Schema: Codable {
	
	public struct Priority: Codable, Equatable, IdentifiedTitle {
		public typealias Identifier = Int
		
		public let identifier: Identifier
		public let title: String
		
        public static func == (lhs: Priority, rhs: Priority) -> Bool {
			return lhs.identifier == rhs.identifier && lhs.title == rhs.title
		}
		
        //  TODO: deprecate it
		public static let low = Priority(identifier: 0, title: "low")
		public static let medium = Priority(identifier: 1, title: "medium")
		public static let high = Priority(identifier: 2, title: "high")
	}
	
	public struct Resolution: Codable, Equatable, IdentifiedTitle {
		public typealias Identifier = Int
		
		public let identifier: Identifier
		public let title: String
		
        public static func == (lhs: Resolution, rhs: Resolution) -> Bool {
			return lhs.identifier == rhs.identifier && lhs.title == rhs.title
		}
		
        //  TODO: remove these defaults gathering from the schema
		public static let open = Resolution(identifier: 0, title: "open")
		public static let resolved = Resolution(identifier: 1, title: "resolved")
		public static let reopened = Resolution(identifier: 2, title: "reopened")
	}
	
	public var priorities: [Priority]
	public var resolutions: [Resolution]
	public var defaultPriority: Priority
	public var defaultResolution: Resolution
	
	public static let start = Schema(priorities: [.low, .medium, .high],
							  resolutions: [.open, .resolved, .reopened],
							  defaultPriority: .medium,
							  defaultResolution: .open)
	
	enum MigrationError: Error {
		case invalidSchema
		case emptySchema
	}
	
	public func resolution(for issue: Issue) -> Resolution? {
		return resolutions.first { $0.identifier == issue.resolutionID }
	}
}

public
protocol IdentifiedTitle {
	associatedtype Identifier: Equatable
	var identifier: Identifier { get }
	var title: String { get }
}

public 
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
