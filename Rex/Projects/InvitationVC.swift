//
//  InvitationVC.swift
//  Rex
//
//  Created by Artemiy Sobolev on 04/09/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Cocoa

class InvitationVC: NSViewController, ModernView, NSTextFieldDelegate {
	
	@IBOutlet weak var searchTextField: NSTextField!
	
	override func viewDidAppear() {
		super.viewDidAppear()
		apply(windowStyle: .dialog)
		
	}
	
	func control(_ control: NSControl, textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>) -> [String] {
		
		return ["anastasiia", "anna"]
	}
	
	
}
