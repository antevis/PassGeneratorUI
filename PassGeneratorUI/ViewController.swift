//
//  ViewController.swift
//  PassGeneratorUI
//
//  Created by Ivan Kazakov on 28/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

	
	@IBOutlet weak var headerStackView: UIStackView!
	@IBOutlet weak var subCatStackView: UIStackView!
	
	@IBOutlet weak var firstNameTextField: UITextField!
	@IBOutlet weak var lastNameTextField: UITextField!
	
	@IBOutlet weak var dobTextField: UITextField!
	@IBOutlet weak var ssnTextField: UITextField!
	
	@IBOutlet weak var projectPicker: UIPickerView!
	
	var headerButtons: [UIButton] = []
	
	var pickerItems: [String] =  []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		var tag: Int = 0
		
		for item in entrantStructure {
			
			let button = composeButton(buttonText: item.category.rawValue, tag: tag, bgColor: UIColor.blueColor(), titleColor: UIColor.grayColor(), action: .parentTapped)
			
			headerStackView.addArrangedSubview(button)
			
			headerButtons.append(button)
			
			tag += 1
		}
		
		if headerButtons.count > 0 {
			
			let button = headerButtons[0]
			
			button.sendActionsForControlEvents(.TouchUpInside)
		}
		
		dobTextField.delegate = self
		ssnTextField.delegate =  self
		projectPicker.delegate = self
		firstNameTextField.delegate = self
		lastNameTextField.delegate = self
		
		dobTextField.tag = fieldTag.dob.rawValue
		ssnTextField.tag = fieldTag.ssn.rawValue
		projectPicker.tag = fieldTag.projectNumber.rawValue
		firstNameTextField.tag = fieldTag.firstName.rawValue
		lastNameTextField.tag = fieldTag.lastName.rawValue
		
		
		
		
		pickerItems = Project.allProjectNumbers()
		
	}
	
	
	func fillChildStack(sender: UIButton!){
		
		for button in headerButtons {
			
			button.setTitleColor(UIColor.grayColor(), forState: .Normal)
		}
		
		sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		
		Aux.removeButtonsFrom(subCatStackView)
		
		let entrantStructureItem: EntrantCat = entrantStructure[sender.tag]
		
		var tag: Int = 0
		
		for item in entrantStructureItem.subCat {
			
			addButtonTo(stack: subCatStackView, text: item.rawValue, tag: tag, bgColor: UIColor.magentaColor(), titleColor: UIColor.grayColor(), action: Selector.childTapped)
			
			tag += 1
		}
	}
	
	func onSubCatSelected(sender: UIButton!) {
		
		for subView in subCatStackView.subviews {
			
			if let button = subView as? UIButton {
				
				button.setTitleColor(UIColor.grayColor(), forState: .Normal)
			}
		}
		
		sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func addButtonTo(stack stackView: UIStackView, text: String, tag: Int, bgColor: UIColor, titleColor: UIColor, action: Selector) {
		
		let button = composeButton(buttonText: text, tag: tag, bgColor: bgColor, titleColor: titleColor, action: action)
		
		stackView.addArrangedSubview(button)
	}
	
	func composeButton(buttonText text: String, tag: Int, bgColor: UIColor, titleColor: UIColor, action: Selector) -> UIButton {
		
		let button = UIButton()
		button.backgroundColor = bgColor
		button.setTitle(text, forState: .Normal)
		button.setTitleColor(titleColor, forState: .Normal)
		button.titleLabel?.textAlignment = .Center
		button.titleLabel?.lineBreakMode = .ByWordWrapping
		button.addTarget(self, action: action, forControlEvents: .TouchUpInside)
		
		button.tag = tag
		
		return button
	}
	
	func textFieldShouldEndEditing(textField: UITextField) -> Bool {
		
		//print(textField.text)
		
		print(pickerItems[projectPicker.selectedRowInComponent(0)])
		
		switch textField.tag {
			
			case fieldTag.dob.rawValue:
				
//				guard let textDate = textField.text where textDate != "" else {
//					
//					return false
//				}
//				
//				if dateValid(textDate) {
//					
//					return true
//					
//				} else {
//					
//					displayAlert(title: "Invalid Date", message: "Date couldn't be recognized")
//					return false
//				}
			
				return true
			
			case fieldTag.ssn.rawValue:
				return true
			case fieldTag.projectNumber.rawValue:
				return true
			default:
				return true
		}
	}
	
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		
		switch textField.tag {
			
			case fieldTag.ssn.rawValue:
				
				return string.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet()) != nil
			
			default: return true
		}
	}
	
	func dateValid(text: String) -> Bool {
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.locale = NSLocale.currentLocale()
		dateFormatter.dateStyle = .ShortStyle
		dateFormatter.timeStyle = .NoStyle
		
		return dateFormatter.dateFromString(text) != nil
	}
	
	func displayAlert(title title: String, message: String) {
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
		
		presentViewController(alert, animated: true, completion: nil)
	}
	
	//MARK: picker conformance
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		
		return pickerItems[row]
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		
		return pickerItems.count
	}
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		
		return 1
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		print(pickerItems[row])
	}
	
	
}

enum fieldTag: Int {
	case dob = 0
	case ssn
	case projectNumber
	case firstName
	case lastName
}

//https://medium.com/swift-programming/swift-selector-syntax-sugar-81c8a8b10df3#.ywjyftjut
private extension Selector {
	
	static let parentTapped = #selector(ViewController.fillChildStack(_:))
	
	static let childTapped = #selector(ViewController.onSubCatSelected(_:))
	
}









