//
//  MockUserIdentityFetcher.swift
//  RexTests
//
//  Created by Sobolev, Artemiy on 8/31/17.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Foundation
@testable import Rex

struct MockUserIdentityFetcher: UserIdentityFetcher {
    
    enum Result {
        case error(Error)
        case userIdentity(String)
    }
    
    let expectedResult: Result
    
    func fetch(queue: DispatchQueue, errorHandler: @escaping (Error) -> Void, successHandler: @escaping (String) -> Void) {
        
        switch expectedResult {
        case .error(let error):
            errorHandler(error)
        case .userIdentity(let userIdentity):
            successHandler(userIdentity)
        }
    }
}
