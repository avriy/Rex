//
//  ProjectSaver.swift
//  Rex
//
//  Created by Artemiy Sobolev on 20/09/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa

public protocol ProjectSaver {
    func saveProjectWithName(_ name: String, image: NSImage?, completion: @escaping (Project) -> Void) -> Progress
}
