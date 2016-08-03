//
//  ViewController.swift
//  PassGeneratorUI
//
//  Created by Ivan Kazakov on 28/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import UIKit

typealias FVP = FieldValidationParameters

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

	
	@IBOutlet weak var headerStackView: UIStackView!
	@IBOutlet weak var subCatStackView: UIStackView!
	
	@IBOutlet weak var dobTextField: UITextField!
	@IBOutlet weak var ssnTextField: UITextField!
	@IBOutlet weak var projectPicker: UIPickerView!
	
	@IBOutlet weak var firstNameTextField: UITextField!
	@IBOutlet weak var lastNameTextField: UITextField!
	
	@IBOutlet weak var companyTextField: UITextField!
	
	@IBOutlet weak var streetTextField: UITextField!
	@IBOutlet weak var cityTextField: UITextField!
	@IBOutlet weak var stateTextField: UITextField!
	@IBOutlet weak var zipTextField: UITextField!
	@IBOutlet weak var validateSwitch: UISwitch!
	
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
		companyTextField.delegate = self
		streetTextField.delegate = self
		cityTextField.delegate = self
		stateTextField.delegate = self
		zipTextField.delegate = self
		
		dobTextField.tag = FVP.fieldTag.dob.rawValue
		ssnTextField.tag = FVP.fieldTag.ssn.rawValue
		projectPicker.tag = FVP.fieldTag.projectNumber.rawValue
		firstNameTextField.tag = FVP.fieldTag.firstName.rawValue
		lastNameTextField.tag = FVP.fieldTag.lastName.rawValue
		companyTextField.tag = FVP.fieldTag.company.rawValue
		streetTextField.tag = FVP.fieldTag.street.rawValue
		cityTextField.tag = FVP.fieldTag.city.rawValue
		stateTextField.tag = FVP.fieldTag.state.rawValue
		zipTextField.tag = FVP.fieldTag.zip.rawValue
		
		pickerItems = Project.allProjectNumbers()
		
		//Make birth date placeholder locale-dependant
		if let dateFormatPlaceHolder = NSDateFormatter.dateFormatFromTemplate("MMddyyyy", options: 0, locale: NSLocale.currentLocale()) {
			
			dobTextField.placeholder = dateFormatPlaceHolder.uppercaseString
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		streetTextField.text = ""
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
		
		var validationFunction: (validatedText: String, len: Int?) -> Bool
		
		var len: Int?
		
		switch textField.tag {
			
			case FVP.fieldTag.dob.rawValue:
				
				validationFunction = dateValid
			
			case FVP.fieldTag.ssn.rawValue:
				
				validationFunction = ssnValid
			
			case FVP.fieldTag.zip.rawValue:
				
				validationFunction = zipValid
			
			case FVP.fieldTag.city.rawValue, FVP.fieldTag.company.rawValue, FVP.fieldTag.firstName.rawValue, FVP.fieldTag.lastName.rawValue, FVP.fieldTag.state.rawValue, FVP.fieldTag.street.rawValue:
				
				validationFunction = lengthValid
				len = FVP().getSpec(textField.tag)?.expectedCharCount
			
			default:
				
				return true
		}
		
		if let candidate = textField.text where validationFunction(validatedText: candidate, len: len) {
			
			textField.backgroundColor = nil //default transparent
			
		} else {
			
			textField.backgroundColor = UIColor(red: 1, green: 123/255.0, blue: 162/255.0, alpha: 1) //pink
		}
		
		return true
		
	}
	
//	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//		
//		return true
//	}
	
	func dateValid(text: String, len: Int? = nil) -> Bool {
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.locale = NSLocale.currentLocale()
		dateFormatter.dateStyle = .ShortStyle
		dateFormatter.timeStyle = .NoStyle
		
		return dateFormatter.dateFromString(text) != nil
	}
	
	func ssnValid(value: String, len: Int? = nil) -> Bool {
		
		let regex = "^\\d{3}-\\d{2}-\\d{4}$"
		
		return valid(value, against: regex)
	}
	
	func zipValid(value: String, len: Int? = nil) -> Bool {
		
		let regex = "\\d{5}"
		
		return valid(value, against: regex)
	}
	
	func lengthValid(value: String, len: Int?) -> Bool {
		
		guard let len = len else {
			
			return false
		}
		
		return value.characters.count <= len
	}
	
	func valid(value: String, against regex: String) -> Bool {
		
		let test = NSPredicate(format: "SELF MATCHES %@", regex)
		return test.evaluateWithObject(value)
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

	@IBAction func generatePassButtonTapped(sender: AnyObject) {
		
		if let passController = storyboard?.instantiateViewControllerWithIdentifier("passViewController") as? PassViewController {
		
			presentViewController(passController, animated: true, completion: nil)
		}
	}
	
}

struct FieldValidationParameters {
	
	enum fieldTag: Int {
		case dob = 0
		case ssn
		case projectNumber
		case firstName
		case lastName
		case company
		case street
		case city
		case state
		case zip
	}
	
	struct CharCountSpec {
		let expectedCharCount: Int
		let mandatoryCharCountMatch: Bool
		let dataType: fieldDataType
	}
	
	enum fieldDataType {
		case text
		case integer
		case date
	}
	
	let charCountByTag: [fieldTag: CharCountSpec] = [
		
		fieldTag.city: CharCountSpec(expectedCharCount: 15, mandatoryCharCountMatch: false, dataType: .text),
		fieldTag.company: CharCountSpec(expectedCharCount: 20, mandatoryCharCountMatch: false, dataType: .text),
		fieldTag.firstName: CharCountSpec(expectedCharCount: 20, mandatoryCharCountMatch: false, dataType: .text),
		fieldTag.lastName: CharCountSpec(expectedCharCount: 20, mandatoryCharCountMatch: false, dataType: .text),
		fieldTag.ssn: CharCountSpec(expectedCharCount: 9, mandatoryCharCountMatch: true, dataType: .integer),
		fieldTag.street: CharCountSpec(expectedCharCount: 100, mandatoryCharCountMatch: false, dataType: .text),
		fieldTag.state: CharCountSpec(expectedCharCount: 2, mandatoryCharCountMatch: true, dataType: .text)
		//fieldTag.zip: CharCountSpec(expectedCharCount: 5, mandatoryCharCountMatch: true, dataType: .integer),
		//fieldTag.dob: CharCountSpec(expectedCharCount: 10, mandatoryCharCountMatch: true, dataType: .date)
	]
	
	func getSpec(tag: Int) -> CharCountSpec? {
		
		guard let ftag = fieldTag(rawValue: tag) else {
			
			return nil
		}
		
		return charCountByTag[ftag]
	}
}


//https://medium.com/swift-programming/swift-selector-syntax-sugar-81c8a8b10df3#.ywjyftjut
private extension Selector {
	
	static let parentTapped = #selector(ViewController.fillChildStack(_:))
	
	static let childTapped = #selector(ViewController.onSubCatSelected(_:))
	
}









