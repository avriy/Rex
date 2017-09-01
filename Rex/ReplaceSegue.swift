//
//  ReplaceSegue.swift
//  Rex
//
//  Created by Artemiy Sobolev on 01/09/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa

/*
Segue to replace `sourceController` with `destinationController`
*/
class ReplaceSegue: NSStoryboardSegue {
	
	func castControllers<T>(type: T.Type) -> (origin: T, destination: T)? {
		guard let origin = sourceController as? T, let destination = destinationController as? T else {
			return nil
		}
		return (origin: origin, destination: destination)
	}
	
	func performAsViewController() {
		guard let (origin, destination) = castControllers(type: NSViewController.self) else {
			fatalError("Failed to perfrom replace segue as controller is not a NSViewController")
		}
		
		let animator = CustomAnimator()
		animator.isAnimated = true
		origin.presentViewController(destination, animator: animator)
	}
	
	func performAsWindowController() {
		guard let (origin, destination) = castControllers(type: NSWindowController.self) else {
			fatalError("Failed to perfrom replace segue as controller is not a NSWindowController")
		}
		
		destination.showWindow(nil)
		origin.close()
	}
	
	override func perform() {
		switch destinationController {
		case is NSViewController:
			performAsViewController()
		case is NSWindowController:
			performAsWindowController()
		default:
			fatalError("Destination view controller is of unknown type")
		}
	}
}

private
extension Array where Element: Equatable {
	mutating func removeElement(element: Element) -> Bool {
		let oldSize = count
		self = filter { $0 != element }
		return count != oldSize
	}
}

class HolderWindow: NSObject, NSWindowDelegate {
	var windows: [NSWindow] = []
	@objc func windowWillClose(_ notification: Notification) {
		let window = notification.object as! NSWindow
		if !windows.removeElement(element: window) {
			print("Error in custon segue!!!")
		}
	}
}

private let holderWindow = HolderWindow()

class CustomAnimator: NSObject, NSViewControllerPresentationAnimator {
	var isAnimated: Bool = true
	
	public func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
		let bottomVC = fromViewController
		let topVC = viewController
		
		let topWindow = NSWindow(contentViewController: topVC)
		topWindow.makeKeyAndOrderFront(AppDelegate.self)
		holderWindow.windows.append(topWindow)
		topWindow.delegate = holderWindow
		bottomVC.view.window?.close()
		
		if  let bottomWindow = bottomVC.view.window {
			let bottomFrame = bottomWindow.frame
			let y = bottomFrame.origin.y + bottomFrame.size.height - topWindow.frame.size.height
			let x = bottomFrame.origin.x
			topWindow.setFrameOrigin(CGPoint(x: x, y: y))
		} else {
			topWindow.setFrameOrigin(.zero)
		}
		
		
		if isAnimated {
			topWindow.alphaValue = 0
			NSAnimationContext.runAnimationGroup({ context in
				context.duration = 0.5
				topWindow.animator().alphaValue = 1
			}, completionHandler: nil)
		}
	}
	
	public func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
		
	}
}
