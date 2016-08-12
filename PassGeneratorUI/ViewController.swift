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
	@IBOutlet weak var pickerContainer: UIView!
	
	@IBOutlet weak var generatePassButton: UIButton!
	@IBOutlet weak var populateDataButton: UIButton!
	
	let headerColor = UIColor(red: 118/255.0, green: 85/255.0, blue: 152/255.0, alpha: 1)
	let childColor = UIColor(red: 48/255.0, green: 40/255.0, blue: 55/255.0, alpha: 1)
	let headerDimmedColor = UIColor(red: 198/255.0, green: 178/255.0, blue: 218/255.0, alpha: 1)
	let childDimmedColor = UIColor(red: 111/255.0, green: 100/255.0, blue: 121/255.0, alpha: 1)
	
	let bgColor = UIColor(red: 210/255.0, green: 204/255.0, blue: 216/255.0, alpha: 1)
	
	let enabledLabelBorderColor = UIColor(red: 133/255.0, green: 128/255.0, blue: 136/255.0, alpha: 1)
	let disabledLabelBorderColor = UIColor(red: 177/255.0, green: 172/255.0, blue: 182/255.0, alpha: 1)
	
	
	var headerButtons: [UIButton] = []
	var childButtons: [UIButton] = []
	
	var pickerItems: [(code: String, project: Project)] =  []
	
	var fieldsByEntrant: [EntrantSubCategory: [UITextField]] = [:]
	var plugValuesDictionary: [UITextField: (noMatch: String, match: String)] = [:]
	
	var currentParentTag: Int = 0
	var currentChildTag: Int = 0
	
	var currentEntrantSubCat: EntrantSubCategory?// EntrantType.Type?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		fillParentStack()
		
		doHeavyLifting()
	}
	
	
	//MARK: UITextFieldDelegate conformance + text field validation
	func textFieldShouldEndEditing(textField: UITextField) -> Bool {
		
		return valueValidationPassedFor(textField)
		
	}
	
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		
		//Enables deletion
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
	
	//Function used in textFieldShouldEndEditing(textField: UITextField) for UITextFieldDelegate conformance as non-restrictive but informative,
	//and later for final validation with the 'restrict' paramenter explicitly set to true
	func valueValidationPassedFor(textField: UITextField, restrict: Bool = false) -> Bool {
		
		var validationFunction: (validatedText: String, len: Int?) -> Bool
		
		var len: Int?
		
		switch textField.tag {
			
		case FVP.fieldTag.dob.rawValue:
			
			validationFunction = Aux.dateValid
			
		case FVP.fieldTag.ssn.rawValue:
			
			validationFunction = Aux.ssnValid
			
		case FVP.fieldTag.zip.rawValue:
			
			validationFunction = Aux.zipValid
			
		case FVP.fieldTag.company.rawValue:
			
			validationFunction = Aux.vendorCompanyValid
			
		case FVP.fieldTag.city.rawValue, FVP.fieldTag.firstName.rawValue, FVP.fieldTag.lastName.rawValue, FVP.fieldTag.state.rawValue, FVP.fieldTag.street.rawValue:
			
			validationFunction = Aux.lengthValid
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
		
		return pickerItems[row].code
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
	
	//MARK: Events Handlers
	@IBAction func generatePassButtonTapped(sender: AnyObject) {
		
		var entrant: EntrantType?
		
		var hourlyFood: HourlyEmployeeCatering?
		var hourlyMaintenance: HourlyEmployeeMaintenance?
		var hourlyRide: HourlyEmployeeRideService?
		
		if let subCat = currentEntrantSubCat {
			
			switch subCat {
				
				case .classicGuest: entrant = classicGuest()
				
				case .freeChileGuest: entrant = freeChild()
				case .generalManager, .shiftManager, .seniorManager: entrant = manager()
				case .hourlyEmployeeFood:
					
					//A little ugly, but works fine
					hourlyFood = hourly()
					entrant = hourlyFood
				
				case .hourlyEmployeeMaintenance:
				
					hourlyMaintenance = hourly()
					entrant = hourlyMaintenance
				
				case .hourlyEmployeeRideServices:
				
					hourlyRide = hourly()
					entrant = hourlyRide
				
				case .contractEmployee: entrant = contractEmployee()
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
	
	
	
	@IBAction func populateDataTapped(sender: AnyObject) {
		
		if let fieldList = entrantFieldList() {
			
			for field in fieldList {
				
				if let fieldData = self.plugValuesDictionary[field], let text = field.text {

					//Inserting bad value
					if text.isEmpty {
						
						field.text = fieldData.noMatch
						
					//Replacing it with good value
					} else if text == fieldData.noMatch {
						
						//custom tweak for free child guest
						if currentEntrantSubCat == EntrantSubCategory.freeChileGuest {
							
							field.text = Aux.shortDateStringFromNsDate(Aux.todayBirthday(year: Aux.year() - 4)!)
							
							break
						}
						
						field.text = fieldData.match
						
						break
					}
				}
			}
		}
	}
	
	//Filling entrant categories
	func fillParentStack() {
		
		var tag: Int = 0
		
		for item in entrantStructure {
			
			let button = composeButton(buttonText: item.category.rawValue, tag: tag, bgColor: headerColor, titleColor: headerDimmedColor, action: .parentTapped, fontSize: 18, bold: true)
			
			headerStackView.addArrangedSubview(button)
			
			headerButtons.append(button)
			
			tag += 1
		}
	}
	
	//Filling entrant subcategories
	func fillChildStack(sender: UIButton!){
		
		self.currentParentTag = sender.tag
		
		for button in headerButtons {
			
			button.setTitleColor(headerDimmedColor, forState: .Normal)
		}
		
		sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		
		Aux.removeAllSubviewsFrom(subCatStackView)
		
		let entrantStructureItem: EntrantCat = entrantStructure[sender.tag]
		
		var tag: Int = 0
		
		for item in entrantStructureItem.subCat {
			
			addButtonTo(stack: subCatStackView, text: item.0.rawValue, tag: tag, bgColor: childColor, titleColor: childDimmedColor, action: Selector.childTapped)
			
			tag += 1
		}
		
		disableAllFields(view)
		
		
		//toggle subCat .TouchUpInside in case of single menu option (relevant for Vendor => Vendor Representative
		//makes no sense to wait for subcategory selection if there is only one.
		if entrantStructureItem.subCat.count == 1 {
			
			currentChildTag = 0
			if let button = subCatStackView.subviews[currentChildTag] as? UIButton {
	
				button.sendActionsForControlEvents(.TouchUpInside)
			}
		}
	}
	
	func onSubCatSelected(sender: UIButton!) {
		
		self.currentChildTag = sender.tag
		
		for subView in subCatStackView.subviews {
			
			if let button = subView as? UIButton {
				
				button.setTitleColor(childDimmedColor, forState: .Normal)
			}
		}
		
		sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		
		clearAllTextFieldsWithin(view)
		
		enableRelevantFields()
	}
	
	//MARK: entrants initialization
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
	
	func hourly<T: HourlyEmployee>() -> T? {
		
		var entrant: T?
		
		if let employeeData = getEmployeeRelevantData() {
			
			do {
				
				try entrant = T(
					fullName: employeeData.dobNameAddress.fullName,
					address: employeeData.dobNameAddress.address,
					ssn: employeeData.ssn,
					birthDate: employeeData.dobNameAddress.birthDate)
				
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
	
	func manager() -> Manager? {
		
		var entrant: Manager?
		
		if let managerData = getManagerRelevantData() {
			
			do {
				try entrant = Manager(
					tier: managerData.tier,
					fullName: managerData.employeeData.dobNameAddress.fullName,
					address: managerData.employeeData.dobNameAddress.address,
					ssn: managerData.employeeData.ssn,
					birthDate: managerData.employeeData.dobNameAddress.birthDate)
				
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
	
	func contractEmployee() -> ContractEmployee? {
		var entrant: ContractEmployee?
		
		if let data = getContractorEmployeeRelevantData() {
			
			do {
				try entrant = ContractEmployee(
					project: data.project,
					fullName: data.employeeData.dobNameAddress.fullName,
					address: data.employeeData.dobNameAddress.address,
					ssn: data.employeeData.ssn,
					birthDate: data.employeeData.dobNameAddress.birthDate)
				
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
	
	func seasonPassGuest() -> SeasonPassGuest? {
		
		var entrant: SeasonPassGuest?
		
		if let data = getDobNameAddressData() {
			
			do {
				try entrant = SeasonPassGuest(birthDate: data.birthDate, fullName: data.fullName, address: data.address)
				
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
	
	func seniorGuest() -> SeniorGuest? {
		var entrant: SeniorGuest?
		
		if let data = getDobNameData() {
			
			do {
				try entrant = SeniorGuest(birthDate: data.birthDate, fullName: data.fullName)
				
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
	
	func vendor() -> Vendor? {
		var entrant: Vendor?
		
		if let data = getDobNameData(), let company = getVendorCompany() {
			
			do {
				
				try entrant = Vendor(company: company, fullName: data.fullName, birthDate: data.birthDate)
				
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
	
	//MARK: Auxilliary (I don't like the word "Helper")
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
		
		let nameDobList: [UITextField] = [dobTextField, firstNameTextField, lastNameTextField]
		
		var nameAddressDobList: [UITextField] = nameDobList
		nameAddressDobList += [streetTextField, cityTextField, stateTextField, zipTextField]
		
		var stdEmployeeFieldList = nameAddressDobList
		stdEmployeeFieldList.append(ssnTextField)
		
		var vendorList = nameDobList
		vendorList.append(companyTextField)
		
		self.fieldsByEntrant = [
			
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
			EntrantSubCategory.vendorRepresentative: vendorList
		]
		
		self.plugValuesDictionary = [
			
			firstNameTextField: (noMatch: "ReallyReallyLongLongName", match: "Henry"),
			lastNameTextField: (noMatch: "ReallyReallyLongLastName", match: "Churchill"),
			
			//Yet matching value for date-of-birth fails for kid entrant due to age restrictions
			dobTextField: (noMatch: "32/32/2032", match: {() -> String in
				
				let date = Aux.todayBirthday(year: 1993)!
				let dateFormatter = NSDateFormatter()
				dateFormatter.dateStyle = .ShortStyle
				
				return dateFormatter.stringFromDate(date)
				}()),
			
			streetTextField: (noMatch: "ReallyReallyLongLongStreetStreetNameName, ReallyReallyLongLongStreetStreetHouseNumberHouseNumber, reallyReally", match: "1 Elm str."),
			cityTextField: (noMatch: "City Of Long, Really Long Names", match: "Los Angeles"),
			stateTextField: (noMatch: "CAL", match: "CA"),
			
			zipTextField: (noMatch: "CA-99999", match: "99999"),
		
			ssnTextField: (noMatch: "5555-5555", match: "555-55-5555"),
			
			companyTextField: (noMatch: "Microsoft", match: "Fedex"),
		]
		
		//self.fieldsByEntrant = fieldsByEntrant
		
		if headerButtons.count > 0 {
			
			let button = headerButtons[0]
			
			button.sendActionsForControlEvents(.TouchUpInside)
		}
		
		self.pickerItems = Project.allProjectNumbers()
		
		//Make birth date placeholder locale-dependant
		if let dateFormatPlaceHolder = NSDateFormatter.dateFormatFromTemplate("MMddyyyy", options: 0, locale: NSLocale.currentLocale()) {
			
			dobTextField.placeholder = "\(dateFormatPlaceHolder.uppercaseString)"
		}
		
		pickerContainer.layer.borderColor = disabledLabelBorderColor.CGColor
		pickerContainer.layer.cornerRadius = 4
		pickerContainer.layer.borderWidth = 2
		
		setTextFieldAttibutes(view)
		
		generatePassButton.layer.cornerRadius = 5
		populateDataButton.layer.cornerRadius = 5
		
	}
	
	func clearAllTextFieldsWithin(view: UIView) {
		
		for subView in view.subviews {
			
			if let textField = subView as? UITextField {
				
				textField.text = ""
			}
			
			clearAllTextFieldsWithin(subView)
		}
	}
	
	func entrantFieldList() -> [UITextField]? {
		
		currentEntrantSubCat = entrantStructure[currentParentTag].subCat[currentChildTag].subCatName
		
		if let currEntrantSubCat = currentEntrantSubCat {
			
			return fieldsByEntrant[currEntrantSubCat]
			
		} else {
			
			return nil
		}
	}
	
	func setTextFieldAttibutes(view: UIView) {
		
		for subview in view.subviews {
			
			if let textField = subview as? UITextField {
				
				if textField.enabled {
					
					textField.layer.borderColor = enabledLabelBorderColor.CGColor
					
				} else {
					
					textField.layer.borderColor = disabledLabelBorderColor.CGColor
				}
				textField.layer.borderWidth = 2
				textField.layer.cornerRadius = 4
				
				//http://stackoverflow.com/questions/7565645/indent-the-text-in-a-uitextfield
				let spacerView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
				textField.leftViewMode = UITextFieldViewMode.Always
				textField.leftView = spacerView
			}
			
			setTextFieldAttibutes(subview)
		}
	}
	
	func composeButton(buttonText text: String, tag: Int, bgColor: UIColor, titleColor: UIColor, action: Selector, fontSize: CGFloat? = 15, bold: Bool? = false) -> UIButton {
		
		let button = UIButton()
		button.backgroundColor = bgColor
		button.setTitle(text, forState: .Normal)
		button.setTitleColor(titleColor, forState: .Normal)
		button.titleLabel?.textAlignment = .Center
		button.titleLabel?.lineBreakMode = .ByWordWrapping
		button.addTarget(self, action: action, forControlEvents: .TouchUpInside)
		
		if let fontSize = fontSize, let font = button.titleLabel?.font {
			
			button.titleLabel?.font = UIFont(name: font.fontName, size: fontSize)
		}
		
		if let _ = bold, let font = button.titleLabel?.font {
			
			button.titleLabel?.font = font.bold()
		}
		
		button.tag = tag
		
		return button
	}
	
	
	
	func addButtonTo(stack stackView: UIStackView, text: String, tag: Int, bgColor: UIColor, titleColor: UIColor, action: Selector, fontSize: CGFloat = 15, bold: Bool = false) {
		
		let button = composeButton(buttonText: text, tag: tag, bgColor: bgColor, titleColor: titleColor, action: action, fontSize: fontSize, bold: bold)
		
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
	
	func disableAllFields(view: UIView) {
		
		for subView in view.subviews {
			
			if let textField = subView as? UITextField {
				
				textField.enabled = false
				textField.backgroundColor = bgColor
				textField.layer.borderColor = disabledLabelBorderColor.CGColor
			}
			
			if let picker = subView as? UIPickerView {
				
				picker.hidden = true
				picker.userInteractionEnabled = false
				pickerContainer.layer.borderColor = disabledLabelBorderColor.CGColor
			}
			
			disableAllFields(subView)
		}
	}
	
	func enableRelevantFields() {
		
		disableAllFields(view) //just in case
		
		let entrantSubCatTuple = entrantStructure[currentParentTag].subCat[currentChildTag]
		
		currentEntrantSubCat = entrantSubCatTuple.subCatName//.entrantType
		
		if let currentEntrant = currentEntrantSubCat, fieldsToEnable = fieldsByEntrant[currentEntrant] {
			
			for field in fieldsToEnable {
				
				field.enabled = true
				field.backgroundColor = UIColor.whiteColor()
				field.layer.borderColor = enabledLabelBorderColor.CGColor
			}
			
			if currentEntrant == EntrantSubCategory.contractEmployee {
				
				projectPicker.userInteractionEnabled = true
				projectPicker.hidden = false
				
				pickerContainer.layer.borderColor = enabledLabelBorderColor.CGColor
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
			
		} catch EntrantError.AddressStreetMissing(let message){
			
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
		
		guard let dobNameData = getDobNameAddressData(), let ssn = retrieveStringValueFrom(ssnTextField, subjectName: "SSN") else {
			
			return nil
		}
		
		return EmployeeRelevantData(dobNameAddress: dobNameData, ssn: ssn)
	}
	
	func getDobNameAddressData() -> DobNameAddressData? {
		
		if
			let currentEntrant = currentEntrantSubCat,
			let fields = fieldsByEntrant[currentEntrant] where validationPassedFor(fields),
			let address = retrieveAddress(),
			let birthDate = retrieveDateValueFrom(dobTextField, subjectName: "Birth Date") {
			
			let fullName = PersonFullName(firstName: firstNameTextField.text, lastName: lastNameTextField.text)
			
			return DobNameAddressData(entrantSubCat: currentEntrant, fields: fields, address: address, birthDate: birthDate, fullName: fullName)
			
		} else {
			
			return nil
		}
	}
	
	func getDobNameData() -> DobNameData? {
		
		if
			let currentEntrant = currentEntrantSubCat,
			let fields = fieldsByEntrant[currentEntrant] where validationPassedFor(fields),
			let birthDate = retrieveDateValueFrom(dobTextField, subjectName: "Birth Date") {
			
			let fullName = PersonFullName(firstName: firstNameTextField.text, lastName: lastNameTextField.text)
			
			return DobNameData(entrantSubCat: currentEntrant, fields: fields, birthDate: birthDate, fullName: fullName)
			
		} else {
			
			return nil
		}
	}
	
	func getManagerRelevantData() -> ManagerRelevantData? {
		
		guard let employeeData = getEmployeeRelevantData(), let tier = getManagerTier() else {
			
			return nil
		}
		
		return ManagerRelevantData(employeeData: employeeData, tier: tier)
	}
	
	func getManagerTier() -> ManagementTier? {
		
		var tier: ManagementTier?
		
		let managerSubCat = entrantStructure[currentParentTag].subCat[currentChildTag].subCatName
		
		switch managerSubCat {
			
			case .generalManager:
				tier = ManagementTier.general
			case .seniorManager:
				tier = ManagementTier.senior
			case .shiftManager:
				tier = ManagementTier.shift
			default:
				break
		}
		
		return tier
	}
	
	func getVendorCompany() -> VendorCompany? {
		
		guard let companyName = companyTextField.text else {
			
			return nil
		}
		
		return VendorCompany(rawValue: companyName)
	}
	
	func getContractorEmployeeRelevantData() -> ContractorEmployeeRelevantData? {
		
		guard let employeeData = getEmployeeRelevantData() else {
			
			return nil
		}
		
		let currentProject = pickerItems[projectPicker.selectedRowInComponent(0)].project
		
		return ContractorEmployeeRelevantData(employeeData: employeeData, project: currentProject)
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
	
	
	
}

struct EmployeeRelevantData {
	
	let dobNameAddress: DobNameAddressData
	let ssn: String
}

struct ManagerRelevantData {
	
	let employeeData: EmployeeRelevantData
	let tier: ManagementTier
}

struct ContractorEmployeeRelevantData {
	let employeeData: EmployeeRelevantData
	let project: Project
}

struct DobNameAddressData {
	
	let entrantSubCat: EntrantSubCategory
	let fields: [UITextField]
	let address: Address
	let birthDate: NSDate
	let fullName: PersonFullName
}

struct DobNameData {
	
	let entrantSubCat: EntrantSubCategory
	let fields: [UITextField]
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
		
		fieldTag.city: CharCountSpec(expectedCharCount: 30, mandatoryCharCountMatch: false, dataType: .text, description: "City"),
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

//http://stackoverflow.com/questions/18862868/setting-bold-font-on-ios-uilabel
private extension UIFont {
	
	func withTraits(traits:UIFontDescriptorSymbolicTraits...) -> UIFont {
		let descriptor = self.fontDescriptor()
			.fontDescriptorWithSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))
		return UIFont(descriptor: descriptor, size: 0)
	}
	
	func bold() -> UIFont {
		return withTraits(.TraitBold)
	}
	
}









