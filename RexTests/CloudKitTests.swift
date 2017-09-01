//
//  CloudKitTests.swift
//  RexTests
//
//  Created by Sobolev, Artemiy on 8/30/17.
//  Copyright © 2017 splyshka. All rights reserved.
//

import XCTest
import CloudKit

class CloudKitTests: XCTestCase {
    
    
    func testRecordIDEquatability() {
        let owner = "avriy"
        let a = CKRecordID(recordName: "a", zoneID: CKRecordZoneID(zoneName: "zone", ownerName: owner))
        let b = CKRecordID(recordName: "a", zoneID: CKRecordZoneID(zoneName: "zone", ownerName: owner))
        
        XCTAssert(a == b, "Record IDs should be equal")
        
    }
    
    func testArchiveUnarchiveStrings() {
        let string = "1234"
        let data = NSKeyedArchiver.archivedData(withRootObject: string)
        guard let objectBack = NSKeyedUnarchiver.unarchiveObject(with: data) as? String else {
            XCTFail("returning type should be a String")
            return
        }
        XCTAssert(string == objectBack, "Saved and retrieved Strings should be the same")
    }
    
}


