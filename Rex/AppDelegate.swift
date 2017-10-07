//
//  AppDelegate.swift
//  Rex
//
//  Created by Artemiy Sobolev on 27/06/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa
import CloudKit

extension Notification.Name {
	static let recordWasCreated = Notification.Name(rawValue: "record was created notification")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		NSApplication.shared.registerForRemoteNotifications(matching: [.alert, .badge, .sound])
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
	
	func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
	}
}
