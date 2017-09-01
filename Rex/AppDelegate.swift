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
		debugPrint("Did receive remote notification")
		let cknotification = CKNotification(fromRemoteNotificationDictionary: userInfo)
		if cknotification.notificationType == .query {
			let queryNotification = cknotification as! CKQueryNotification
			
			if queryNotification.queryNotificationReason == .recordCreated {
				let database = CKContainer.default().database(with: queryNotification.databaseScope)
				
				database.fetch(withRecordID: queryNotification.recordID!) { (record, error) in
					if let record = record {
						DispatchQueue.main.async {
							debugPrint("Posting notification")
							NotificationCenter.default.post(name: .recordWasCreated, object: nil, userInfo: ["record" : record, "notification" : queryNotification])
						}
					} else if let error = error {
						fatalError("Failed to fetch with \(error)")
					}
				}
			}
		}
		
	}
}
