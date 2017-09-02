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
	@IBOutlet weak var progressIndicator: NSProgressIndicator!
	
	private let initializationGroup = DispatchGroup()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let databaseScope = ProcessInfo.processInfo.isTestEnvironment ? CKDatabaseScope.private : .public
		applicationContext = AppContext(databaseScope: databaseScope)
		
		initializationGroup.enter()
		initializationGroup.enter()		
		
		applicationContext.accountCoordinator.activateAccountIfNeeded(errorHandler: { error in
			self.initializationGroup.leave()
		}) { [unowned self] in
			self.initializationGroup.leave()
		}
		
		initializationGroup.notify(queue: .main) { [unowned self] in
			switch applicationContext.accountCoordinator.accountState {
			case .active:
				self.performSegue(withIdentifier: .openProjectList, sender: nil)
			case .notActive:
				//	show activate button and label that account was not activated
				return
			case .pending:
				fatalError("Account is still pending after activation handler is called")
			}
		}
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		progressIndicator.startAnimation(nil)
		
		apply(windowStyle: .dialog)
		initializationGroup.leave()
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
