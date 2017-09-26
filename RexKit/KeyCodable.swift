//
//  KeyCodable.swift
//  Rex
//
//  Created by Sobolev, Artemiy on 8/30/17.
//  Copyright © 2017 splyshka. All rights reserved.
//

import CloudKit

protocol KeyCodable {
    var value: String { get }
}

extension KeyCodable where Self: RawRepresentable, Self.RawValue == String {
    var value: String {
        return rawValue
    }
}

enum RexErrors: Error {
    case noValueForKey(String)
}

extension CKRecord {
    subscript <T: CKRecordValue>(key: KeyCodable) -> T? {
        get {
            return self[key.value] as? T
        } set {
            self[key.value] = newValue
        }
    }
    
    func getValue<T>(for key: KeyCodable) throws -> T {
        
        guard let result = self[key.value] as? T else {
            throw RexErrors.noValueForKey(key.value)
        }
        
        return result
    }
    
    func getRecordID(for key: KeyCodable) throws -> CKRecordID {
        guard let reference = self[key.value] as? CKReference else {
            throw RexErrors.noValueForKey(key.value)
        }
        return reference.recordID
    }
    
    func set<T: CKRecordValue>(value: T, for key: KeyCodable) {
        self[key.value] = value
    }
}
