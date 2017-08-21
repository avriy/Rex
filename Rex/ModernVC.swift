//
//  ModernVC.swift
//  Rex
//
//  Created by Artemiy Sobolev on 21/08/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa

enum WindowStyle {
	///  style suitable for onboarding dialogs
	case dialog
	///  style for window where user spends most of the time
	case editor
}

protocol ModernView {
	func apply(windowStyle: WindowStyle, adding style: NSWindow.StyleMask)
}

extension ModernView where Self: NSWindowController {
	
	func apply(windowStyle: WindowStyle, adding style: NSWindow.StyleMask = []) {
		window!.applyStyle(widowStyle: windowStyle, adding: style)
		window!.contentView?.addTransparency()
	}
	
}

extension ModernView where Self: NSViewController {
	
	func apply(windowStyle: WindowStyle, adding style: NSWindow.StyleMask = []) {
		//      Window should be present to tune appearance
		view.window!.applyStyle(widowStyle: windowStyle, adding: style)
		view.addTransparency()
	}
}

private
extension NSView {
	
	func addTransparency() {
		
		let effectView = NSVisualEffectView()
		effectView.material = .light
		let firstSubview = effectView.subviews.first
		
		addSubview(effectView, positioned: .below, relativeTo: firstSubview)
		effectView.translatesAutoresizingMaskIntoConstraints = false
		
		let views = ["effectView" : effectView]
		let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[effectView]|", options: [], metrics: nil, views: views)
		let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[effectView]|", options: [], metrics: nil, views: views)
		
		addConstraints(verticalConstraints + horizontalConstraints)
	}
	
}

private
extension NSWindow {
	func applyStyle(widowStyle ws: WindowStyle, adding style: NSWindow.StyleMask = []) {
		switch ws {
		case .dialog:
			titlebarAppearsTransparent = true
			styleMask.insert([.fullSizeContentView, .unifiedTitleAndToolbar])
			styleMask.remove([.resizable, .miniaturizable])
			titleVisibility = .hidden
			isMovableByWindowBackground = true
			
		case .editor:
			titlebarAppearsTransparent = true
			styleMask.insert([.fullSizeContentView, .unifiedTitleAndToolbar])
		}
		styleMask.insert(style)
	}
}

