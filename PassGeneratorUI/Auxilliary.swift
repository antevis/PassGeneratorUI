//
//  Auxilliary.swift
//  PassGenerator
//
//  Created by Ivan Kazakov on 14/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import Foundation
import UIKit

typealias Aux = Auxilliary

class Auxilliary {
	
	class func composeGreetingConsidering(birthday: NSDate?, forEntrant fullName: PersonFullName?) -> String {
		
		//Every entrant will eventually get at least "Hello" in the Entrant rules.
		//Well, next 4 lines seem ugly. Knowing of ?? operator, will probably fix later.
		var addressing: String = ""
		
		if let name = fullName?.firstName {
			
			addressing += ", \(name)"
		}
		
		var greeting: String = "Hello\(addressing)"
		
		if let birthday = birthday {
			
			//Borrowed from @thedan84
			let calendar = NSCalendar.currentCalendar()
			let today = calendar.components([.Month, .Day], fromDate: NSDate())
			let bday = calendar.components([.Month, .Day], fromDate: birthday)
			
			if today.month == bday.month && today.day == bday.day {
				
				greeting += ", Happy Birthday!"
				
			} else {
				
				greeting += "!"
			}
		}
		
		return greeting
	}
	
	class func dateFromDMY(day day: Int, month: Int, year: Int) -> NSDate? {
		
		let dateComponents: NSDateComponents = NSDateComponents()
		dateComponents.day = day
		dateComponents.month = month
		dateComponents.year = year
		
		let calendar = NSCalendar.currentCalendar()
		
		return calendar.dateFromComponents(dateComponents)
	}
	
	class func todayBirthday(year year: Int) -> NSDate? {
		
		let calendar = NSCalendar.currentCalendar()
		
		let todayComponents = calendar.components([.Month, .Day], fromDate: NSDate())
		
		let dateComponents: NSDateComponents = NSDateComponents()
		dateComponents.year = year
		dateComponents.day = todayComponents.day
		dateComponents.month = todayComponents.month
		
		return calendar.dateFromComponents(dateComponents)
	}
	
	class func yearAsStringFrom(date: NSDate) -> String {
		
		let calendar = NSCalendar.currentCalendar()
		let components = calendar.components([.Day , .Month , .Year], fromDate: date)
		
		return  components.year.description
	}
	
	class func monthAsStringFrom(date: NSDate) -> String {
		
		let calendar = NSCalendar.currentCalendar()
		let components = calendar.components([.Day , .Month , .Year], fromDate: date)
		
		return  components.month.description
	}
	
	class func dayAsStringFrom(date: NSDate) -> String {
		
		let calendar = NSCalendar.currentCalendar()
		let components = calendar.components([.Day , .Month , .Year], fromDate: date)
		
		return  components.day.description
	}
	
	class func year() -> Int {
		
		let comps = NSCalendar.currentCalendar().components([.Year], fromDate: NSDate())
		
		return comps.year
	}
	
	class func fullYearsFrom(date: NSDate) -> Int {
		
		let components = NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: NSDate(), options: .MatchFirst)
		
		return components.year
	}
	
	class func discountTestOf(rules: EntryRules) {
		
		guard let discounts = rules.discountAccess where discounts.count > 0 else {
			
			print("No discounts found")
			
			return
		}
		
		for discount in discounts {
			
			print(discount.description())
		}
	}
	
	class func  removeAllSubviewsFrom(superView: UIView) {
		
		for subView in superView.subviews {
			
//			if subView is UIButton {
//				
//				subView.removeFromSuperview()
//			}
			
			subView.removeFromSuperview()
		}
	}
	
	class func digits() -> NSCharacterSet {
		
		return NSCharacterSet.decimalDigitCharacterSet()
	}
	
	class func digitsWith(extraChars extras: String) -> NSCharacterSet {
		
		let mutableChars: NSMutableCharacterSet = NSMutableCharacterSet(charactersInString: extras)
		mutableChars.formUnionWithCharacterSet(digits())
		
		let result = mutableChars as NSCharacterSet
		
		return result
	}
	
	class func nsDateFrom(string string: String) -> NSDate? {
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.locale = NSLocale.currentLocale()
		dateFormatter.dateStyle = .ShortStyle
		dateFormatter.timeStyle = .NoStyle
		
		return dateFormatter.dateFromString(string)
	}
	
	
	class func dateValid(text: String, len: Int? = nil) -> Bool {
		
		return Aux.nsDateFrom(string: text) != nil
	}
	
	class func ssnValid(value: String, len: Int? = nil) -> Bool {
		
		let regex = "^\\d{3}-\\d{2}-\\d{4}$"
		
		return valid(value, against: regex)
	}
	
	class func zipValid(value: String, len: Int? = nil) -> Bool {
		
		let regex = "\\d{5}"
		
		return valid(value, against: regex)
	}
	
	class func lengthValid(value: String, len: Int?) -> Bool {
		
		guard let len = len else {
			
			return false
		}
		
		return value.characters.count <= len && value.characters.count > 0
	}
	
	class func vendorCompanyValid(value: String, len: Int?) -> Bool {
		
		return VendorCompany.AllVendorCompanyNames().contains(value)
	}
	
	//https://github.com/jpotts18/SwiftValidator/blob/master/SwiftValidator/Rules/RegexRule.swift
	class func valid(value: String, against regex: String) -> Bool {
		
		let test = NSPredicate(format: "SELF MATCHES %@", regex)
		return test.evaluateWithObject(value)
	}
	
	class func composeButton(buttonText text: String, tag: Int, bgColor: UIColor, titleColor: UIColor, cornerRadius radius: CGFloat? = nil) -> UIButton {
		
		let button = UIButton()
		button.backgroundColor = bgColor
		button.setTitle(text, forState: .Normal)
		button.setTitleColor(titleColor, forState: .Normal)
		button.titleLabel?.textAlignment = .Center
		button.titleLabel?.lineBreakMode = .ByWordWrapping
		
		if let radius = radius {
			
			button.layer.cornerRadius = radius
		}
		
		button.tag = tag
		
		return button
	}
	
	class func createInfoLabelWith(message text: String, labelColor: UIColor, fontSize: CGFloat = 16) -> UILabel {
		
		let infoLabel = UILabel()
		
		infoLabel.text = text
		infoLabel.font = UIFont.boldSystemFontOfSize(fontSize)
		infoLabel.textColor = labelColor
		infoLabel.textAlignment = .Center
		
		return infoLabel
	}
	
	class func playNegativeSound() -> Void {
		let sfx = SoundFX()
		sfx.loadDeniedSound()
		sfx.playSound()
	}
	
	class func playPositiveSound() -> Void {
		let sfx = SoundFX()
		sfx.loadGrantedSound()
		sfx.playSound()
	}
	
}