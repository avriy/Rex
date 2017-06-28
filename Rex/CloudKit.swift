//
//  CloudKit.swift
//  Rex
//
//  Created by Artemiy Sobolev on 28/06/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit

extension CKContainer {
	func requestPermissionsIfNeeded(errorHandler eh: @escaping (Error) -> Void, successHandler sh: @escaping () -> Void) {
		
		accountStatus { [weak self] (status, error) in
			if let error = error {
				return eh(error)
			}
			
			guard status != .available else {
				return sh()
			}
			
			self?.requestApplicationPermission(.userDiscoverability) { (status, error) in
				if let error = error {
					return eh(error)
				}
				sh()
			}
		}
	}
}
