//
//  PassGenerator.swift
//  PassGenerator
//
//  Created by Ivan Kazakov on 11/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import Foundation
import UIKit

//MARK: Global Scope Dictionaries

//Probably not the best approach to declare dictionaries as high as this level
let AreaAccessByProject: [Project: [Area]] = [
	
	Project.oneOne: [Area.amusement, Area.rideControl],
	Project.oneTwo: [Area.amusement, Area.rideControl, Area.maintenance],
	Project.oneThree: Area.fullAccess(),
	Project.twoOne: [Area.office],
	Project.twoTwo: [Area.kitchen, Area.maintenance]
]

let AreaAccessByVendor: [VendorCompany: [Area]] = [
	
	VendorCompany.acme: [Area.kitchen],
	VendorCompany.fedex: [Area.maintenance, Area.office],
	VendorCompany.nwElectrical: Area.fullAccess(),
	VendorCompany.orkin: [Area.amusement, Area.rideControl, Area.kitchen]
]

//MARK: enums

enum Area: String {
	
	case amusement = "Amusement Area"
	case kitchen = "Kitchen Area"
	case rideControl = "Ride Control Area"
	case maintenance = "Maintenance Area"
	case office = "Office Area"
	
	func testAccess(entryRules: EntryRules, makeSound: Bool = true) -> (accessGranted: Bool, message: String) {
		
		let sfx: SoundFX? = makeSound ? SoundFX() : nil
		
		let accessGranted = entryRules.areaAccess.contains(self)
		
		var message: String
		
		if accessGranted {
			
			message = "Access Granted"
			
			sfx?.loadGrantedSound()
		} else {
			
			message = "Access Denied"
			
			sfx?.loadDeniedSound()
		}
		
		sfx?.playSound()
		
		return (accessGranted, message)
	}
}

extension Area {
	
	static func fullAccess() -> [Area] {
		
		return allAreas()
	}
	
	static func allAreas() -> [Area] {
		
		//Missing enum iteration in almost every project so far.:(
		return [Area.amusement, Area.kitchen, Area.rideControl, Area.maintenance, Area.office]
	}
	
	//For button generation purposes (to avoid any tagging misplacement due to some hypothetical collection re-ordering)
	static func areaDictionary() -> [Int: Area] {
		
		return [0: Area.amusement, 1: Area.kitchen, 2: Area.rideControl, 3: Area.maintenance, 4: Area.office]
	}
	
	static func allAreaNames() -> [String] {
		
		var areaNames: [String] = []
		
		for area in allAreas() {
			
			areaNames.append(area.rawValue)
		}
		
		return areaNames
	}
}

enum DiscountSubject: String {
	
	case food = "Food Discount"
	case merchandise = "Merchandize discount"
}

enum ManagementTier: String {
	
	case shift = "Shift"
	case general = "General"
	case senior = "Senior"
}

enum EntrantError: ErrorType {
	
	case NotAKidAnymore(yearThreshold: Int)
	
	case FirstNameMissing(message: String)
	case LastNameMissing(message: String)
	
	//these three represent non-optional types in all initializers, thus not handling them until part 2, when filling in the UI fields
	case SsnMissing(message: String)
	case ManagerTierMissing(message: String)
	case dateOfBirthMissing(message: String)
	
	//these four being thrown from the Address init, but handling defered until UI in Part 2
	case AddressStreetMissing(message: String)
	case AddressCityMissing(message: String)
	case AddressStateMissing(message: String)
	case AddressZipMissing(message: String)
}

enum Project: String {
	
	case oneOne = "1001"
	case oneTwo = "1002"
	case oneThree = "1003"
	case twoOne = "2001"
	case twoTwo = "2002"
	
	static func allProjects() -> [Project] {
		
		return [oneOne, oneTwo, oneThree, twoOne, twoTwo]
	}
	
	static func allProjectNumbers() -> [(code: String, project: Project)] {
		
		var projectNumbers: [(code: String, project: Project)] = []
		
		for project in allProjects() {
			
			projectNumbers.append((project.rawValue, project))
		}
		
		return projectNumbers
	}
}

enum VendorCompany: String {
	
	case acme = "Acme"
	case orkin = "Orkin"
	case fedex = "Fedex"
	case nwElectrical = "NW Electrical"
	
	static func allVendorCompanies() -> [VendorCompany] {
		
		return [acme, orkin, fedex, nwElectrical]
	}
	
	static func AllVendorCompanyNames() -> [String] {
		
		var companies: [String] = []
		
		for vendorCompany in allVendorCompanies() {
			
			companies.append(vendorCompany.rawValue)
		}
		
		return companies
	}
}


//MARK: structs

struct RideAccess {
	
	let unlimitedAccess: Bool
	let skipLines: Bool
	let seeEntrantAccessRules: Bool //Uncomment in Part 2
	
	
	
	func description() -> String {
		
		var result: String = ""
		
		for (_, specValue) in self.rideAccessSpecification {
			
			result += "\(testAccess(self.unlimitedAccess, trueText: specValue.positiveTitle, falseText: specValue.negativeTitle).message)\r"
		}
		
		return result
		
//		let rideAccess = "\(testAccess(self.unlimitedAccess, trueText: rideAccessSpecification[0]?.positiveTitle ?? "Access Granted", falseText: rideAccessSpecification[0]?.negativeTitle ?? "Access Denied").message)\r"
//		
//		let canSkip = "\(testAccess(self.skipLines, trueText: "Can Skip Lines", falseText: "Cannot Skip Lines").message)\r"
//		
//		let seeRules = "\(testAccess(self.seeEntrantAccessRules, trueText: "Can See Entrant Access Rules", falseText: "Can't See Entrant Access Rules").message)\r"
//		
//		return "\(rideAccess)\(canSkip)\(seeRules)"
	}
	
	func testAccess(parameter: Bool, trueText: String = "Yes", falseText: String = "No", makeSound: Bool = true) -> (param: Bool, message: String) {
		
		let sfx: SoundFX? = makeSound ? SoundFX() : nil
		
		var message: String
		
		if parameter {
			
			message = trueText
			
			sfx?.loadGrantedSound()
			
		} else {
			
			message = falseText
			
			sfx?.loadDeniedSound()
		}
		
		sfx?.playSound()
		
		return (parameter, message)
	}
	
	func permissions() -> String {
		
		var desc: String = ""
		
		for (_, specValue) in rideAccessSpecification {
			
			desc = addDescriptionTo(desc, basedOn: specValue.ruleValue, additionText: specValue.positiveTitle, marker: "•")
		}
		
		return desc
	}
	
	func addDescriptionTo(text: String, basedOn condition: Bool, additionText: String, marker: String) -> String {
		
		var result: String = text
		
		if condition {
			
			if text.characters.count > 0 {
				
				result += ", "
				
			} else {
				
				result += "\(marker) "
			}
			
			result += additionText
		}
		
		return result
	}
}

extension RideAccess {
	
	var rideAccessSpecification: [Int: (ruleValue: Bool, positiveTitle: String, negativeTitle: String, description: String)] {
		
		get {
			
			return [
				0: (self.unlimitedAccess, "Unlimited Rides", "No Rides Access", "Rides"),
				1: (self.skipLines, "Can Skip Lines", "Can't Skip Lines", "Priority Access"),
				2: (self.seeEntrantAccessRules, "Can See Entrant Rules", "Can't See Entrant Rules", "Entrant Rules Information")]
		}
	}
}


struct DiscountParams {
	
	let subject: DiscountSubject
	let discountValue: Double
	
	func description() -> String {
		
		return "Has discount of \(discountValue)% on \(subject)"
	}
}

struct EntryRules {
	
	let areaAccess: [Area]
	let rideAccess: RideAccess
	let discountAccess: [DiscountParams]?
	let greeting: String
	
}

struct PersonFullName {
	
	let firstName: String?
	let lastName: String?
}

struct Address {
	
	let streetAddress: String
	let city: String
	let state: String
	let zip: String
	
	init(street: String?, city: String?, state: String?, zip: String?) throws {
		
		guard let street = street else {
			
			throw EntrantError.AddressStreetMissing(message: "*********ERROR*********\rStreet address missing\r*********ERROR*********\n")
		}
		guard let city = city else {
			
			throw EntrantError.AddressCityMissing(message: "*********ERROR*********\rCity missing\r*********ERROR*********\n")
		}
		guard let state = state else {
			
			throw EntrantError.AddressStateMissing(message: "*********ERROR*********\rState missing\r*********ERROR*********\n")
		}
		guard let zip = zip else {
			
			throw EntrantError.AddressZipMissing(message: "*********ERROR*********\rZIP-code missing\r*********ERROR*********\n")
		}
		
		self.city = city
		self.state = state
		self.streetAddress = street
		self.zip = zip
		
	}
}

//MARK: protocols

//Most protocols below deliberately define a single value, for maximum resilience in constructing objects

protocol Riding {
	
	var accessRules: RideAccess { get }
}

//Most entrants should conform to this
protocol DiscountClaimant {
	
	var discounts: [DiscountParams] { get }
}

//Hourly Employee, Manager, Season Pass Guest, Senior Guest, ContractEmployee, Vendor
protocol FullNameProvider {
	
	var fullName: PersonFullName? { get }
}

//Hourly Employee, Manager, Season Pass Guest, Contract Employee
protocol AddressProvider {
	
	var address: Address { get }
}

//Free Child Guest, Hourly Employee, Manager, Season Pass Guest, Senior Guest, Contract Employee, Vendor
protocol BirthdayProvider {
	
	var birthDate: NSDate? { get }
}

//Manager
protocol ManagementTierProvider {
	
	var tier: ManagementTier { get }
}

protocol DescriptionProvider {
	
	var description: String { get }
}

//Describes any type of entrant. Extended to BirthdayProvider for implementation of extra credit
//FullNameProvider - for optional names for all entrants.
protocol EntrantType: Riding, BirthdayProvider, FullNameProvider, DescriptionProvider {
	
	//var greeting: String { get }
	var accessibleAreas: [Area] { get }
	
	func swipe() -> EntryRules
}

//extension Entrant {
//	
//	func swipe() -> EntryRules {
//		
//		return EntryRules(areaAccess: accessibleAreas, rideAccess: accessRules, discountAccess: nil, greeting: greeting)
//	}
//}

protocol ProjectDependant {
	
	var project: Project { get }
}

//Vendor, For Part 2
protocol VendorType: EntrantType {

	var vendorCompany: VendorCompany { get }
	var visitDate: NSDate? { get set }
}

//MARK: Entrant classes

//defines Employee properties - to be extended for each specific type of employee
//May seem over-complicated, but allows Hourly employees to be initialized in 3 lines of code
class Employee: EntrantType, AddressProvider, DiscountClaimant {
	
	//Since SSN being requested from employees only, be it here
	let ssn: String
	let accessRules: RideAccess
	let accessibleAreas: [Area]
	let fullName: PersonFullName?
	let address: Address
	let birthDate: NSDate?
	let discounts: [DiscountParams]
	//let greeting: String
	let description: String
	
	init(accessibleAreas: [Area], accessRules: RideAccess, discounts: [DiscountParams], fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate, description: String) throws {
		
		guard fullName.firstName != nil else {
			
			throw EntrantError.FirstNameMissing(message: "*********ERROR*********\rFirst Name Missing\r*********ERROR*********\n")
		}
		
		guard fullName.lastName != nil else {
			
			throw EntrantError.LastNameMissing(message: "*********ERROR*********\rLast Name Missing\r*********ERROR*********\n")
		}
		
		self.ssn = ssn
		self.accessibleAreas = accessibleAreas
		self.accessRules = accessRules
		self.fullName = fullName
		self.address = address
		self.birthDate = birthDate
		self.discounts = discounts
		
		//self.greeting = Aux.composeGreetingConsidering(birthDate, forEntrant: fullName)
		
		self.description = description
	}
	
	convenience init(accessibleAreas: [Area], fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate, description: String) throws {
		
		let accessRules = RideAccess(unlimitedAccess: true, skipLines: false, seeEntrantAccessRules: false)
		
		let discounts: [DiscountParams] = [
			
			DiscountParams(subject: .food, discountValue: 15),
			DiscountParams(subject: .merchandise, discountValue: 25)
		]
		
		
		try self.init(accessibleAreas: accessibleAreas, accessRules: accessRules, discounts: discounts,fullName: fullName, address: address, ssn: ssn, birthDate: birthDate, description: description)
	}
	
	func swipe() -> EntryRules {
		
		let greeting = Aux.composeGreetingConsidering(self.birthDate, forEntrant: self.fullName)
		
		return EntryRules(areaAccess: accessibleAreas, rideAccess: accessRules, discountAccess: discounts, greeting: greeting)
	}
}

//To encapsulate all common guest properties.
class Guest: EntrantType {
	
	var birthDate: NSDate?
	var fullName: PersonFullName?
	//let greeting: String
	let accessRules: RideAccess
	let accessibleAreas: [Area]
	let description: String
	
	init(birthDate: NSDate? = nil, fullName: PersonFullName? = nil, accessRules: RideAccess, description: String) {
		
		self.accessibleAreas = [.amusement]
		
		self.accessRules = accessRules
		
		if let birthday = birthDate {
			
			self.birthDate = birthday
		}
		
		self.description = description
		
		self.fullName = fullName
	}
	
	func swipe() -> EntryRules {
		
		let greeting = Aux.composeGreetingConsidering(birthDate, forEntrant: fullName)
		
		return EntryRules(areaAccess: accessibleAreas, rideAccess: accessRules, discountAccess: nil, greeting: greeting)
	}
}