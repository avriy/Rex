//
//  CloudAccountCoordinator.swift
//  Rex
//
//  Created by Sobolev, Artemiy on 8/30/17.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Foundation
import CloudKit

public protocol UserIdentityFetcher {
	associatedtype UserIDType: Equatable
	
	func fetch(queue: DispatchQueue, errorHandler: @escaping (Error) -> Void, successHandler: @escaping (UserIDType) -> Void)
}

public
struct CloudKitUserRecordFetcher: UserIdentityFetcher {
	let container: CKContainer
	
	public func fetch(queue: DispatchQueue, errorHandler: @escaping (Error) -> Void, successHandler: @escaping (CKRecordID) -> Void) {
		
		container.fetchUserRecordID { (userRecordID, error) in
			queue.async {
				if let error = error {
					errorHandler(error)
					return
				}
				
				if let urid = userRecordID {
					successHandler(urid)
				}
			}
		}
	}
}

public let CloudAccountCoordinatorAccountKey = "accountID"

public class CloudAccountCoordinator<Fetcher: UserIdentityFetcher> {
    
    public enum AccountState {
        case notActive, pending, active
    }
    
    private let store: KeyValueStore
    private let fetcher: Fetcher
    
    public private(set) var accountState: AccountState = .notActive
    
    public init(store: KeyValueStore, fetcher: Fetcher) {
        self.store = store; self.fetcher = fetcher
    }
    
	public var userRecordID: Fetcher.UserIDType? {
		get {
			guard let valueForKey: Data = store[CloudAccountCoordinatorAccountKey] else {
				return nil
			}
			return NSKeyedUnarchiver.unarchiveObject(with: valueForKey) as? Fetcher.UserIDType
		} set {
			store[CloudAccountCoordinatorAccountKey] = newValue.flatMap(NSKeyedArchiver.archivedData(withRootObject:))
		}
	}
    
    func handle(userRecordID: Fetcher.UserIDType) {

        guard let previousRecordID = self.userRecordID else {
			self.userRecordID = userRecordID
			return
        }
		
        //  account has changed
        if previousRecordID != userRecordID {
            store.deleteAllEntities()
            self.userRecordID = userRecordID
        }
    }
    
	public func activateAccountIfNeeded(errorHandler: @escaping (Error) -> Void, completion: @escaping () -> Void = {}) {
        
        guard accountState == .notActive else {
            return
        }
        
        accountState = .pending
        
        fetcher.fetch(queue: .main, errorHandler: { [weak self] error in
            errorHandler(error)
            self?.accountState = .notActive
        }) { [weak self] (recordIDType) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.handle(userRecordID: recordIDType)
            strongSelf.accountState = .active
            completion()
        }
    }
    
}

public protocol KeyValueStore: class {
	subscript <T>(value: String) -> T? { get set }
	
	func deleteAllEntities()
}

extension UserDefaults: KeyValueStore {
	
	public subscript <T>(key: String) -> T? {
		get {
			return value(forKey: key) as? T
		} set {
			setValue(newValue, forKey: key)
		}
	}
	
	public func deleteAllEntities() {
		fatalError("Not implemented yet")
	}
}
