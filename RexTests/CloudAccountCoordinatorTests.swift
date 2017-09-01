//
//  CloudAccountCoordinatorTests.swift
//  RexTests
//
//  Created by Sobolev, Artemiy on 8/31/17.
//  Copyright © 2017 splyshka. All rights reserved.
//

import XCTest
@testable import Rex

class DictionaryKeyValueStore: KeyValueStore {
    var dictionary: [String: Any] = [:]
    
    subscript <T>(key: String) -> T? {
        get {
            return dictionary[key] as? T
        } set {
            dictionary[key] = newValue
        }
    }
    
    func deleteAllEntities() {
        dictionary = [:]
    }
}

class CloudAccountCoordinatorTests: XCTestCase {

    func testWillStoreIdentityInStorage() {
        
        let store = DictionaryKeyValueStore()
        let fetcher = MockUserIdentityFetcher(expectedResult: .userIdentity("1234"))
        
        let coordinator = CloudAccountCoordinator<MockUserIdentityFetcher>(store: store, fetcher: fetcher)
        
        let exp = expectation(description: "Wait till account will be fullfilled")
        coordinator.activateAccountIfNeeded(errorHandler: unexpectedErrorHandler(for: exp)) {
            XCTAssert(coordinator.accountState == .active, "Account must be present")
            XCTAssert(coordinator.userRecordID == "1234", "should be equal")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: .timeout, handler: nil)
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
