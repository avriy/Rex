//
//  ProjectVM.swift
//  Rex
//
//  Created by Artemiy Sobolev on 08/10/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Foundation
import RexKit

@objc final class ProjectVM: NSObject {
	
	@objc let project: Project
	
	init(project: Project) {
		self.project = project
	}
	
}
