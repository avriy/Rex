//
//  Scene.swift
//  Rex
//
//  Created by Artemiy Sobolev on 02/10/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa

protocol ModeledView: class {
	associatedtype ViewModelType: ViewModel
	
	func bind(to viewModel: ViewModelType)
}

class Router {
	
	private let scene: Scene
	
	private var children: [Router] = []

	init(scene: Scene) {
		self.scene = scene
	}
	
	func add(child: Router) {
		children.append(child)
	}
	
}

final class Scene {
	
	enum ViewContext {
		case viewController(NSViewController)
		case windowController(NSWindowController)
		case root
	}
	
	private let viewContext: ViewContext
	private let viewModel: ViewModel
	private let binder: () -> Void
	
	init<ViewControllerType: NSViewController & ModeledView>(viewController: ViewControllerType, viewModel: ViewControllerType.ViewModelType) {
		binder = { [unowned viewController, unowned viewModel] in
			viewController.bind(to: viewModel)
		}
		self.viewModel = viewModel
		self.viewContext = .viewController(viewController)
	}

	init<ViewModelType: ViewModel>(viewModel: ViewModelType) {
		binder = {
			
		}
		self.viewModel = viewModel
		self.viewContext = .root
	}
	
	func present() {
		binder()
		// present view controller
	}
	
	func dissmiss() {
		// dissmiss view controller
	}
}

// master-detail - mail example
@objc class Mail: NSObject {
}

class MasterViewModel: NSObject, ViewModel {
	@objc dynamic var selectedMail: Mail?
}

class MasterViewController: NSViewController, ModeledView {
	func bind(to viewModel: MasterViewModel) {
	}
}

class DetailViewModel: NSObject, ViewModel {
	@objc dynamic var selectedMail: Mail?
}

class DetailViewController: NSViewController, ModeledView {
	func bind(to viewModel: DetailViewModel) {
	}
}

class SplitRouter: Router {
	
	func setup() {
		let masterViewModel = MasterViewModel()
		let detailViewModel = DetailViewModel()
		detailViewModel.bind(NSBindingName("selectedMail"), to: masterViewModel, withKeyPath: #keyPath(MasterViewModel.selectedMail))
		
		let masterScene = Scene(viewController: MasterViewController(), viewModel: masterViewModel)
		
		let detailScene = Scene(viewController: DetailViewController(), viewModel: detailViewModel)
		
		add(child: Router(scene: masterScene))
		add(child: Router(scene: detailScene))
	}
}



