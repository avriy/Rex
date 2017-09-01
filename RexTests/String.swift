//
//  String.swift
//  RexTests
//
//  Created by Sobolev, Artemiy on 8/31/17.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Foundation

extension String {
    
    static func random(withLenght length: Int) -> String {
        let charSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let c = charSet.characters.map { String($0) }
        var s = ""
        for _ in 1...length {
            s.append(c[Int(arc4random()) % c.count])
        }
        return s
    }
}
