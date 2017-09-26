//
//  CreateProjectVMTests.swift
//  RexTests
//
//  Created by Artemiy Sobolev on 03/09/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import XCTest
@testable import RexKit
@testable import Rex

struct DummyProjectSaver: ProjectSaver {
	func saveProjectWithName(_ name: String, image: NSImage?, completion: @escaping (Project) -> Void) -> Progress {
		DispatchQueue.main.async {
			let project = Project(name: name)
			completion(project)
		}
		return Progress()
	}
}

class CreateProjectVMTests: XCTestCase {
	
	private let context = AppContext()
	private let dummyImage = NSImage(named: NSImage.Name.bonjour)!
	
	func newViewModel() -> CreateProjectViewModel {
		return CreateProjectViewModel(projectSaver: DummyProjectSaver()) 
	}
	
	func testViewModelInitialization() {
		let viewModel = newViewModel()
		XCTAssert(viewModel.isProcessing == false)
		XCTAssert(viewModel.canCreateProject == false)
	}
	
	func testViewModelWhenSettingName() {
		let viewModel = newViewModel()
		viewModel.name = "Dummy project"
		XCTAssert(viewModel.isProcessing == false)
		XCTAssert(viewModel.canCreateProject == true)
	}
	
	func testViewModelAfterCreation() {
		let viewModel = newViewModel()
		viewModel.name = "Dummy project"
		
		let _ = viewModel.create {
			
		}
		
		XCTAssert(viewModel.isProcessing == true)
		XCTAssert(viewModel.canCreateProject == false)
	}
	
}
