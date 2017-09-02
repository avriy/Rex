//
//  Progress.swift
//  Rex
//
//  Created by Artemiy Sobolev on 02/09/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa

extension Progress {
	
	func makeIntermediate() {
		totalUnitCount = 0
		completedUnitCount = 0
		assert(isIndeterminate)
	}
}

extension NSProgressIndicator {
	
	func bind(to progress: Progress) {
		fatalError("Not implemented")
//		bind(NSAnimateBinding, to: self, withKeyPath: #keyPath(progress), options: [NSValueTransformerNameBindingOption: NSValueTransformerName.isNotNilTransformerName])
//		bind(.animate, to: progress, withKeyPath: #keyPath(Progress.isActive))
	}
	
}

