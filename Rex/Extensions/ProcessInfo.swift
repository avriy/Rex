//
//  ProcessInfo.swift
//  Rex
//
//  Created by Artemiy Sobolev on 20/09/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Foundation

extension ProcessInfo {
	var isTestEnvironment: Bool {
		return arguments.contains("TEST")
	}
}
