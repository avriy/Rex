//
//  CloudAccountCoordinatorTests.swift
//  RexTests
//
//  Created by Sobolev, Artemiy on 8/31/17.
//  Copyright © 2017 splyshka. All rights reserved.
//

import XCTest
@testable import Rex
@testable import RexKit

class DictionaryKeyValueStore: KeyValueStore {
    var dictionary: [String: Any] = [:]
	var deleteWasCalled = false
    
    subscript <T>(key: String) -> T? {
        get {
            return dictionary[key] as? T
        } set {
            dictionary[key] = newValue
        }
    }
    
    func deleteAllEntities() {
        dictionary = [:]
		deleteWasCalled = true
    }
}

class CloudAccountCoordinatorTests: XCTestCase {

	
	func testDummyKeyValueStorageCanHoldValues() {
		
		let store = DictionaryKeyValueStore()
		let randomString = UUID().uuidString
		store[CloudAccountCoordinatorAccountKey] = randomString
		guard let randomSringBack: String = store[CloudAccountCoordinatorAccountKey] else {
			XCTFail("Store should contain value")
			return
		}
		XCTAssert(randomSringBack == randomString)
	}
	
    func testWillStoreIdentityInStorage() {
        
        let store = DictionaryKeyValueStore()
		let identity = UUID().uuidString
        let fetcher = MockUserIdentityFetcher(expectedResult: .userIdentity(identity))
        
        let coordinator = CloudAccountCoordinator<MockUserIdentityFetcher>(store: store, fetcher: fetcher)
        
        let exp = expectation(description: "Wait till account will be fullfilled")
        coordinator.activateAccountIfNeeded(errorHandler: unexpectedErrorHandler(for: exp)) {
            XCTAssert(coordinator.accountState == .active, "Account must be present")
            XCTAssert(coordinator.userRecordID == identity, "should be equal")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: .timeout)
    }

	func testWillDropStorageOnAccountChange() {
		
		let store = DictionaryKeyValueStore()
		
		let firstIdentity = UUID().uuidString
		let firstFetcher = MockUserIdentityFetcher(expectedResult: .userIdentity(firstIdentity))
		let firstCoordinator = CloudAccountCoordinator<MockUserIdentityFetcher>(store: store, fetcher: firstFetcher)
		
		let secondIdentity = UUID().uuidString
		let secondFetcher = MockUserIdentityFetcher(expectedResult: .userIdentity(secondIdentity))
		let secondCoordinator = CloudAccountCoordinator<MockUserIdentityFetcher>(store: store, fetcher: secondFetcher)
		let exp = expectation(description: "Test will finish fetching data from 2 fetchrs")
		firstCoordinator.activateAccountIfNeeded(errorHandler: unexpectedErrorHandler(for: exp)) {
			secondCoordinator.activateAccountIfNeeded(errorHandler: self.unexpectedErrorHandler(for: exp)) {
				XCTAssert(secondCoordinator.userRecordID == secondIdentity, "After changing account all coordinators should have new identity")
				XCTAssert(firstCoordinator.userRecordID == secondIdentity, "After changing account all coordinators should have new identity")
				XCTAssert(store.deleteWasCalled, "When changing account, drop store should be called")
				exp.fulfill()
			}
		}
		waitForExpectations(timeout: .timeout)
	}
}

extension XCTestCase {
    func unexpectedErrorHandler(for expectation: XCTestExpectation) -> ((Error) -> Void) {
        return { error in
            XCTFail("Failed with \(error)")
            expectation.fulfill()
        }
    }
}
