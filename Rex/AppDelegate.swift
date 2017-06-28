//
//  AppDelegate.swift
//  Rex
//
//  Created by Artemiy Sobolev on 27/06/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
}
