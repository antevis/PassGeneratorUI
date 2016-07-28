//
//  Auxilliary.swift
//  PassGenerator
//
//  Created by Ivan Kazakov on 14/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import Foundation

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
}