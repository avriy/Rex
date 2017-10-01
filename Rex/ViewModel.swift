//
//  ViewModel.swift
//  Rex
//
//  Created by Artemiy Sobolev on 27/09/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import RexKit
import CloudKit

protocol ContextDepending {
	var context: AppContext { get }
}

protocol ViewModel {
}

extension ContextDepending where Self: ViewModel {
	var context: AppContext {
		return applicationContext
	}
}

extension ContextDepending where Self: NSViewController {
	var context: AppContext {
		return applicationContext
	}
}


private var applicationContext: AppContext!

/// Responsible for lazy application context initialiazation
class AppContextManager {
	
	private let initializationGroup = DispatchGroup()
	
	func start(with continuationHandler: @escaping (CloudAccountCoordinator<CloudKitUserRecordFetcher>.AccountState) -> Void) {
		
		let databaseScope = ProcessInfo.processInfo.isTestEnvironment ? CKDatabaseScope.private : .public
		applicationContext = AppContext(databaseScope: databaseScope)
		
		initializationGroup.enter()
		initializationGroup.enter()
		
		applicationContext.accountCoordinator.activateAccountIfNeeded(errorHandler: { error in
			self.initializationGroup.leave()
		}) { [unowned self] in
			self.initializationGroup.leave()
		}
		
		initializationGroup.notify(queue: .main) {
			continuationHandler(applicationContext.accountCoordinator.accountState)
		}
	}
	
	func proceed() {
		initializationGroup.leave()
	}
	
}
