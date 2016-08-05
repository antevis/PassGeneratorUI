//
//  ViewController.swift
//  PassGeneratorUI
//
//  Created by Ivan Kazakov on 28/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

//Credits for regex validation. Not sure it's required here but still..
/*The MIT License

Copyright (c) 2014-2015 Jeff Potter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.*/

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
	
	var headerButtons: [UIButton] = []
	var childButtons: [UIButton] = []
	
	var pickerItems: [String] =  []
	
	var fieldsByEntrant: [EntrantSubCategory: [UITextField]] = [:]
	
	var currentParentTag: Int = 0
	var currentChildTag: Int = 0
	
	var currentEntrant: EntrantSubCategory?// EntrantType.Type?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		fillParentStack()
		
		doHeavyLifting()
		
		
	}
	
	override func viewWillAppear(animated: Bool) {
		streetTextField.text = ""
	}
	
	//MARK: UITextFieldDelegate conformance + text field validation
	func textFieldShouldEndEditing(textField: UITextField) -> Bool {
		
		return valueValidationPassedFor(textField)
		
	}
	
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		
		if string.characters.count == 0 {
			
			return true
		}
		
		switch textField.tag {
			
			case FVP.fieldTag.zip.rawValue:
				
				return string.rangeOfCharacterFromSet(Aux.digits()) != nil
			
			case FVP.fieldTag.ssn.rawValue:
				
				return string.rangeOfCharacterFromSet(Aux.digitsWith(extraChars: "-")) != nil
			
			case FVP.fieldTag.dob.rawValue:
				
				return string.rangeOfCharacterFromSet(Aux.digitsWith(extraChars: "/.-")) != nil
				
			default: return true
		}
		
	}
	
	func dateValid(text: String, len: Int? = nil) -> Bool {
		
		return Aux.nsDateFrom(string: text) != nil
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
		
		return value.characters.count <= len && value.characters.count > 0
	}
	
	func vendorCompanyValid(value: String, len: Int?) -> Bool {
		
		return VendorCompany.AllVendorCompanyNames().contains(value.lowercaseString) //going case-insensitive for simplicity
	}
	
	//https://github.com/jpotts18/SwiftValidator/blob/master/SwiftValidator/Rules/RegexRule.swift
	func valid(value: String, against regex: String) -> Bool {
		
		let test = NSPredicate(format: "SELF MATCHES %@", regex)
		return test.evaluateWithObject(value)
	}
	
	func validationPassedFor(fields: [UITextField]) -> Bool {
		
		for field in fields {
			
			if !valueValidationPassedFor(field, restrict: true) {
				
				displayAlertRespectiveTo(field)
				
				return false
			}
		}
		
		return true
	}
	
	func valueValidationPassedFor(textField: UITextField, restrict: Bool = false) -> Bool {
		
		var validationFunction: (validatedText: String, len: Int?) -> Bool
		
		var len: Int?
		
		switch textField.tag {
			
		case FVP.fieldTag.dob.rawValue:
			
			validationFunction = dateValid
			
		case FVP.fieldTag.ssn.rawValue:
			
			validationFunction = ssnValid
			
		case FVP.fieldTag.zip.rawValue:
			
			validationFunction = zipValid
			
		case FVP.fieldTag.company.rawValue:
			
			validationFunction = vendorCompanyValid
			
		case FVP.fieldTag.city.rawValue, FVP.fieldTag.firstName.rawValue, FVP.fieldTag.lastName.rawValue, FVP.fieldTag.state.rawValue, FVP.fieldTag.street.rawValue:
			
			validationFunction = lengthValid
			len = FVP().getSpec(textField.tag)?.expectedCharCount
			
		default:
			
			return true
		}
		
		if let candidate = textField.text where validationFunction(validatedText: candidate, len: len) {
			
			textField.backgroundColor = nil //default transparent
			
		} else {
			
			textField.backgroundColor = UIColor(red: 1, green: 123/255.0, blue: 162/255.0, alpha: 1) //pink
			
			if restrict {
				
				displayAlertRespectiveTo(textField)
				
				return false
			}
		}
		
		return true
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
	
	//MARK: Events
	@IBAction func generatePassButtonTapped(sender: AnyObject) {
		
		var entrant: EntrantType?
		
		if let subCat = currentEntrant {
			
//			let fieldsToValidate = fieldsByEntrant[subCat]
			
			switch subCat {
				
				case .classicGuest: entrant = classicGuest()
				case .contractEmployee: entrant = contractEmployee()
				case .freeChileGuest: entrant = freeChild()
				case .generalManager, .shiftManager, .seniorManager: entrant = manager()
				case .hourlyEmployeeFood: entrant = hourlyFood()
				case .hourlyEmployeeMaintenance: entrant = hourlyMaintenance()
				case .hourlyEmployeeRideServices: entrant = hourlyRide()
				case .seasonPassGuest: entrant = seasonPassGuest()
				case .seniorGuest: entrant = seniorGuest()
				case .vendorRepresentative: entrant = vendor()
				case .vipGuest: entrant = vipGuest()
			}
		}
				
		if let entrant = entrant, passController = storyboard?.instantiateViewControllerWithIdentifier("passViewController") as? PassViewController {
			
			passController.entrant = entrant
		
			presentViewController(passController, animated: true, completion: nil)
		}
	}
	
	func classicGuest() -> ClassicGuest? {
		
		return ClassicGuest()
	}
	
	func vipGuest() -> VipGuest? {
		
		return VipGuest()
	}
	
	func freeChild() -> FreeChildGuest? {
		
		var entrant: FreeChildGuest?
		
		guard let dateString = dobTextField.text, let birthDate = Aux.nsDateFrom(string: dateString) else {
			
			displayAlert(title: "Error", message: "Birth date couldn't be recognized.")
			
			return nil
		}
		
		do {
			
			try entrant = FreeChildGuest(birthDate: birthDate)
			
		} catch EntrantError.NotAKidAnymore(let yearThreshold) {
			
			displayAlert(title: "Error", message: "Looks too grown-up for \(yearThreshold)-year old:)")
			
		} catch {
			
			fatalError()
		}
		
		return entrant
	}
	
//	func hourly<T: Employee>() -> T? {
//		
//		var entrant: T?
//		
//		if
//			let employeeData = getEmployeeRelevantData() {
//			
//			do {
//				
//				try entrant = T(fullName: employeeData.fullName, address: employeeData.address, ssn: employeeData.ssn, birthDate: employeeData.birthDate)
//				
//			} catch EntrantError.FirstNameMissing(let message) {
//				
//				displayAlert(title: "Error", message: message)
//				
//			} catch EntrantError.LastNameMissing(let message) {
//				
//				displayAlert(title: "Error", message: message)
//				
//			} catch {
//				
//				fatalError()
//			}
//		}
//		
//		return entrant
//	}
	
	func hourlyFood() -> HourlyEmployeeCatering? {
		
		var entrant: HourlyEmployeeCatering?
		
		if
			let employeeData = getEmployeeRelevantData() {
			
			do {
				
				try entrant = HourlyEmployeeCatering(fullName: employeeData.fullName, address: employeeData.address, ssn: employeeData.ssn, birthDate: employeeData.birthDate)
				
			} catch EntrantError.FirstNameMissing(let message) {
				
				displayAlert(title: "Error", message: message)
				
			} catch EntrantError.LastNameMissing(let message) {
				
				displayAlert(title: "Error", message: message)
				
			} catch {
				
				fatalError()
			}
		}
		
		return entrant
	}
	
	func hourlyRide() -> HourlyEmployeeRideService? {
		var entrant: HourlyEmployeeRideService?
		return entrant
	}
	
	func hourlyMaintenance() -> HourlyEmployeeMaintenance? {
		var entrant: HourlyEmployeeMaintenance?
		return entrant
	}
	
	func manager() -> Manager? {
		var entrant: Manager?
		return entrant
	}
	
	func seasonPassGuest() -> SeasonPassGuest? {
		var entrant: SeasonPassGuest?
		return entrant
	}
	
	func seniorGuest() -> SeniorGuest? {
		var entrant: SeniorGuest?
		return entrant
	}
	
	func contractEmployee() -> ContractEmployee? {
		var entrant: ContractEmployee?
		return entrant
	}
	
	func vendor() -> Vendor? {
		var entrant: Vendor?
		return entrant
	}
	
	func onSubCatSelected(sender: UIButton!) {
		
		self.currentChildTag = sender.tag
		
		for subView in subCatStackView.subviews {
			
			if let button = subView as? UIButton {
				
				button.setTitleColor(UIColor.grayColor(), forState: .Normal)
			}
		}
		
		sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		
		enableRelevantFields()
	}
	
	//MARK: Auxilliary (Yes, I don't like the word "Helper")
	func doHeavyLifting() {
		
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
		
		let nameDobList: [UITextField] = [firstNameTextField, lastNameTextField, dobTextField]
		
		var nameAddressDobList: [UITextField] = nameDobList
		nameAddressDobList += [streetTextField, cityTextField, stateTextField, zipTextField]
		
		var stdEmployeeFieldList = nameAddressDobList
		stdEmployeeFieldList.append(ssnTextField)
		
		let fieldsByEntrant: [EntrantSubCategory: [UITextField]] = [
			
			EntrantSubCategory.classicGuest: [],
			EntrantSubCategory.contractEmployee: nameAddressDobList,
			EntrantSubCategory.freeChileGuest: [dobTextField],
			EntrantSubCategory.generalManager: stdEmployeeFieldList,
			EntrantSubCategory.hourlyEmployeeFood: stdEmployeeFieldList,
			EntrantSubCategory.hourlyEmployeeMaintenance: stdEmployeeFieldList,
			EntrantSubCategory.hourlyEmployeeRideServices: stdEmployeeFieldList,
			EntrantSubCategory.seasonPassGuest: nameAddressDobList,
			EntrantSubCategory.seniorGuest: nameDobList,
			EntrantSubCategory.seniorManager: stdEmployeeFieldList,
			EntrantSubCategory.shiftManager: stdEmployeeFieldList,
			EntrantSubCategory.vendorRepresentative: nameDobList
		]
		
		self.fieldsByEntrant = fieldsByEntrant
		
		if headerButtons.count > 0 {
			
			let button = headerButtons[0]
			
			button.sendActionsForControlEvents(.TouchUpInside)
		}
		
		self.pickerItems = Project.allProjectNumbers()
		
		//Make birth date placeholder locale-dependant
		if let dateFormatPlaceHolder = NSDateFormatter.dateFormatFromTemplate("MMddyyyy", options: 0, locale: NSLocale.currentLocale()) {
			
			dobTextField.placeholder = dateFormatPlaceHolder.uppercaseString
		}
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
	
	func fillParentStack() {
		
		var tag: Int = 0
		
		for item in entrantStructure {
			
			let button = composeButton(buttonText: item.category.rawValue, tag: tag, bgColor: UIColor.blueColor(), titleColor: UIColor.grayColor(), action: .parentTapped)
			
			headerStackView.addArrangedSubview(button)
			
			headerButtons.append(button)
			
			tag += 1
		}
	}
	
	func fillChildStack(sender: UIButton!){
		
		self.currentParentTag = sender.tag
		
		for button in headerButtons {
			
			button.setTitleColor(UIColor.grayColor(), forState: .Normal)
		}
		
		sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		
		Aux.removeButtonsFrom(subCatStackView)
		
		let entrantStructureItem: EntrantCat = entrantStructure[sender.tag]
		
		var tag: Int = 0
		
		for item in entrantStructureItem.subCat {
			
			addButtonTo(stack: subCatStackView, text: item.0.rawValue, tag: tag, bgColor: UIColor.magentaColor(), titleColor: UIColor.grayColor(), action: Selector.childTapped)
			
			tag += 1
		}
		
		disableAllFields()
	}
	
	func addButtonTo(stack stackView: UIStackView, text: String, tag: Int, bgColor: UIColor, titleColor: UIColor, action: Selector) {
		
		let button = composeButton(buttonText: text, tag: tag, bgColor: bgColor, titleColor: titleColor, action: action)
		
		stackView.addArrangedSubview(button)
	}
	
	func displayAlert(title title: String, message: String) {
		
		if self.presentedViewController == nil {
		
			let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(alert, animated: true, completion: nil)
			
		}
	}
	
	func displayAlertRespectiveTo(textField: UITextField) {
		
		var message: String
		
		switch textField.tag {
			
		case FVP.fieldTag.dob.rawValue:
			
			message = "Unable to Recognize Date of Birth"
			
		case FVP.fieldTag.ssn.rawValue:
			
			message = "Unable to Recognize Social Security Number"
			
		case FVP.fieldTag.zip.rawValue:
			
			message = "ZIP-Code Should Contain 5 Digits"
			
		case FVP.fieldTag.company.rawValue:
			
			message = "Vendor Company Not Recognized"
			
		case FVP.fieldTag.city.rawValue, FVP.fieldTag.firstName.rawValue, FVP.fieldTag.lastName.rawValue, FVP.fieldTag.state.rawValue, FVP.fieldTag.street.rawValue:
			
			let spec = FVP().getSpec(textField.tag)
			
			message = "\(spec?.description ?? "Value") Shouldn't be Empty and Shouldn't exceed \(spec?.expectedCharCount.description ?? "Given threshold of") characters"
			
		default:
			
			message = "Unable to Recognize Given Value"
		}
		
		displayAlert(title: "Error", message: message)
	}
	
	func disableAllFields() {
		
		for subView in view.subviews {
			
			if let textField = subView as? UITextField {
				
				textField.enabled = false
			}
		}
	}
	
	func enableRelevantFields() {
		
		disableAllFields() //just in case
		
		let entrantSubCatTuple = entrantStructure[currentParentTag].subCat[currentChildTag]
		
		currentEntrant = entrantSubCatTuple.subCatName//.entrantType
		
		if let currentEntrant = currentEntrant, fieldsToEnable = fieldsByEntrant[currentEntrant] {
			
			for field in fieldsToEnable {
				
				field.enabled = true
			}
		}
	}
	
	func retrieveAddress() -> Address? {
		
		var address: Address?
		
		do {
			try address = Address(street: streetTextField.text, city: cityTextField.text, state: stateTextField.text, zip: zipTextField.text)
			
		} catch EntrantError.AddressCityMissing(let message) {
			
			displayAlert(title: "Error", message: message)
			
			
		} catch EntrantError.AddressStateMissing(let message) {
			displayAlert(title: "Error", message: message)
			
			
			
		}catch EntrantError.AddressStreetMissing(let message){
			
			displayAlert(title: "Error", message: message)
			
			
		} catch EntrantError.AddressZipMissing(let message) {
			
			displayAlert(title: "Error", message: message)
			
			
		} catch {
			
			fatalError()
			
		}
		
		return address
	}
	
	func retrieveStringValueFrom(textField: UITextField, subjectName: String) -> String? {
		
		if let candidate = textField.text {
			
			return candidate
			
		} else {
			
			displayAlert(title: "Error", message: "\(subjectName) Not Recognized")
			
			return nil
		}
	}
	
	func retrieveDateValueFrom(textField: UITextField, subjectName: String) -> NSDate? {
		
		if let dateString = textField.text, let date = Aux.nsDateFrom(string: dateString) {
			
			return date
			
		} else {
			
			displayAlert(title: "Error", message: "\(subjectName) Not Recognized")
			
			return nil
		}
	}
	
	func getEmployeeRelevantData() -> EmployeeRelevantData? {
		
		if
			let currentEntrant = currentEntrant,
			let fields = fieldsByEntrant[currentEntrant] where validationPassedFor(fields),
			let address = retrieveAddress(),
			let ssn = retrieveStringValueFrom(ssnTextField, subjectName: "SSN"),
			let birthDate = retrieveDateValueFrom(dobTextField, subjectName: "Birth Date") {
			
			let fullName = PersonFullName(firstName: firstNameTextField.text, lastName: lastNameTextField.text)
			
			return EmployeeRelevantData(entrantSubCat: currentEntrant, fields: fields, address: address, ssn: ssn, birthDate: birthDate, fullName: fullName)
			
		} else {
			
			return nil
		}
	}
	
	
}

struct EmployeeRelevantData {
	
	let entrantSubCat: EntrantSubCategory
	let fields: [UITextField]
	let address: Address
	let ssn: String
	let birthDate: NSDate
	let fullName: PersonFullName
	
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
		let description: String
	}
	
	enum fieldDataType {
		case text
		case integer
		case date
	}
	
	let charCountByTag: [fieldTag: CharCountSpec] = [
		
		fieldTag.city: CharCountSpec(expectedCharCount: 15, mandatoryCharCountMatch: false, dataType: .text, description: "City"),
		fieldTag.company: CharCountSpec(expectedCharCount: 20, mandatoryCharCountMatch: false, dataType: .text, description: "Company Name"),
		fieldTag.firstName: CharCountSpec(expectedCharCount: 20, mandatoryCharCountMatch: false, dataType: .text, description: "First Name"),
		fieldTag.lastName: CharCountSpec(expectedCharCount: 20, mandatoryCharCountMatch: false, dataType: .text, description: "Last Name"),
		fieldTag.ssn: CharCountSpec(expectedCharCount: 11, mandatoryCharCountMatch: true, dataType: .integer, description: "Social Security Number"),
		fieldTag.street: CharCountSpec(expectedCharCount: 100, mandatoryCharCountMatch: false, dataType: .text, description: "Street address"),
		fieldTag.state: CharCountSpec(expectedCharCount: 2, mandatoryCharCountMatch: true, dataType: .text, description: "State"),
		fieldTag.zip: CharCountSpec(expectedCharCount: 5, mandatoryCharCountMatch: true, dataType: .integer, description: "ZIP-Code"),
		fieldTag.dob: CharCountSpec(expectedCharCount: 10, mandatoryCharCountMatch: true, dataType: .date, description: "Date of Birth")
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









