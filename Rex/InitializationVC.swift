//
//  InitializationVC.swift
//  Rex
//
//  Created by Sobolev, Artemiy on 8/30/17.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa
import CloudKit

private var applicationContext: AppContext!

extension ProcessInfo {
	var isTestEnvironment: Bool {
		return arguments.contains("TEST")
	}
}

/// Starting VC stat should be shown during initialization
class InitializationVC: NSViewController, ModernView {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let databaseScope = ProcessInfo.processInfo.isTestEnvironment ? CKDatabaseScope.private : .public
		applicationContext = AppContext(databaseScope: databaseScope)
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		
		apply(windowStyle: .dialog)
		applicationContext.accountCoordinator.activateAccountIfNeeded(errorHandler: defaultErrorHandler) { [unowned self] in
			self.performSegue(withIdentifier: .openProjectList, sender: nil)
		}
	}
}

protocol ContextDepending {
	var context: AppContext { get }
}

extension ContextDepending where Self: NSViewController {
	var context: AppContext {
		return applicationContext
	}
}
