//
//  InitializationVC.swift
//  Rex
//
//  Created by Sobolev, Artemiy on 8/30/17.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa
import CloudKit
import RexKit

private var applicationContext: AppContext!

/// Starting VC stat should be shown during initialization
class InitializationVC: NSViewController, ModernView {
	@IBOutlet weak var progressIndicator: NSProgressIndicator!
	
	private let appContextManager = AppContextManager()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		appContextManager.start { [unowned self] accountState in
			switch accountState {
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
		appContextManager.proceed()
	}
}
