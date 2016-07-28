//
//  Entrants.swift
//  PassGenerator
//
//  Created by Ivan Kazakov on 14/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import Foundation

class ClassicGuest: Guest {
	
	init(birthDate: NSDate? = nil, fullName: PersonFullName? = nil, description: String = "Classic Guest") {
		
		let accessRules = RideAccess(unlimitedAccess: true, skipLines: false, seeEntrantAccessRules: false)
		super.init(birthDate: birthDate, fullName: fullName, accessRules: accessRules, description: description)
	}
}

class VipGuest: Guest, DiscountClaimant {
	
	let discounts: [DiscountParams]
	
	init(birthDate: NSDate? = nil, fullName: PersonFullName? = nil, description: String = "VIP Guest") {
		
		let accessRules = RideAccess(unlimitedAccess: true, skipLines: true, seeEntrantAccessRules: false)
		
		discounts = [
			
			DiscountParams(subject: .food, discountValue: 10),
			DiscountParams(subject: .merchandise, discountValue: 20)
		]
		
		super.init(birthDate: birthDate, fullName: fullName, accessRules: accessRules, description: description)
	}
	
	override func swipe() -> EntryRules {
		
		let greeting = Aux.composeGreetingConsidering(birthDate, forEntrant: fullName)
		
		return EntryRules(areaAccess: accessibleAreas, rideAccess: accessRules, discountAccess: discounts, greeting: greeting)
	}
}

//Due to equality of discount params for VIP and seasonal, the latter could be made inheriting from VIP + conforming to AddressProvider, but the match considered as coincidencial, not intentional
class SeasonPassGuest: Guest, DiscountClaimant, AddressProvider {
	
	let discounts: [DiscountParams]
	let address: Address
	
	init(birthDate: NSDate, fullName: PersonFullName, address: Address) {
		
		let accessRules = RideAccess(unlimitedAccess: true, skipLines: true, seeEntrantAccessRules: false)
		
		//declaration extracted for clarity
		let description: String = "Season Pass Guest"
		
		self.discounts = [
			
			DiscountParams(subject: .food, discountValue: 10),
			DiscountParams(subject: .merchandise, discountValue: 20)
		]
		
		self.address = address
		
		super.init(birthDate: birthDate, fullName: fullName, accessRules: accessRules, description: description)
	}
	
	override func swipe() -> EntryRules {
		
		let greeting = Aux.composeGreetingConsidering(birthDate, forEntrant: fullName)
		
		return EntryRules(areaAccess: accessibleAreas, rideAccess: accessRules, discountAccess: discounts, greeting: greeting)
	}
}

class SeniorGuest: Guest, DiscountClaimant {
	
	let discounts: [DiscountParams]
	
	init(birthDate: NSDate, fullName: PersonFullName) {
		
		let description: String = "Senior Guest"
		
		let accessRules = RideAccess(unlimitedAccess: true, skipLines: true, seeEntrantAccessRules: false)
		
		self.discounts = [
			
			DiscountParams(subject: .food, discountValue: 10),
			DiscountParams(subject: .merchandise, discountValue: 10)
		]
		
		super.init(birthDate: birthDate, fullName: fullName, accessRules: accessRules, description: description)
	}
	
	override func swipe() -> EntryRules {
		
		let greeting = Aux.composeGreetingConsidering(birthDate, forEntrant: fullName)
		
		return EntryRules(areaAccess: accessibleAreas, rideAccess: accessRules, discountAccess: discounts, greeting: greeting)
	}
}

class FreeChildGuest: ClassicGuest {
	
	init(birthDate: NSDate, fullName: PersonFullName? = nil, description: String = "Free Child Guest") throws {
		
		if Aux.fullYearsFrom(birthDate) > 5 {
			
			throw EntrantError.NotAKidAnymore(yearThreshold: 5)
		}
		
		super.init(birthDate: birthDate, fullName: fullName, description: description)
	}
}



class HourlyEmployeeCatering: Employee {
	
	convenience init(fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate) throws {
		
		let accessibleAreas: [Area] = [.amusement, .kitchen]
		
		try self.init(accessibleAreas: accessibleAreas, fullName: fullName, address: address, ssn: ssn, birthDate: birthDate, description: "Hourly Employee Food Services")
	}
}

class HourlyEmployeeRideService: Employee {
	
	convenience init(fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate) throws {
		
		let accessibleAreas: [Area] = [.amusement, .rideControl]
		
		try self.init(accessibleAreas: accessibleAreas, fullName: fullName, address: address, ssn: ssn, birthDate: birthDate, description: "Hourly Employee Ride Services")
	}
}

class HourlyEmployeeMaintenance: Employee {
	
	convenience init(fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate) throws {
		
		let accessibleAreas: [Area] = [.amusement, .kitchen, .rideControl, .maintenance]
		
		try self.init(accessibleAreas: accessibleAreas, fullName: fullName, address: address, ssn: ssn, birthDate: birthDate, description: "Hourly Employee Maintenance")
	}
}

class Manager: Employee, ManagementTierProvider {
	
	let tier: ManagementTier
	
	init(tier: ManagementTier, fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate) throws {
		
		self.tier = tier
		
		let accessibleAreas: [Area] = Area.fullAccess()
		let accessRules = RideAccess(unlimitedAccess: true, skipLines: false, seeEntrantAccessRules: false)
		
		let discounts: [DiscountParams] = [
			
			DiscountParams(subject: .food, discountValue: 25),
			DiscountParams(subject: .merchandise, discountValue: 25)
		]
		
		try super.init(accessibleAreas: accessibleAreas, accessRules: accessRules, discounts: discounts, fullName: fullName, address: address, ssn: ssn, birthDate: birthDate, description: "\(tier.rawValue) Manager")
	}
}

class ContractEmployee: Employee, ProjectDependant {
	
	let project: Project
	
	init(project: Project, fullName: PersonFullName, address: Address, ssn: String, birthDate: NSDate) throws {
		
		self.project = project
		
		let accessibleAreas: [Area] = AreaAccessByProject[project] ?? []
		let accessRules = RideAccess(unlimitedAccess: false, skipLines: false, seeEntrantAccessRules: true)
		
		try super.init(accessibleAreas: accessibleAreas, accessRules: accessRules, discounts: [], fullName: fullName, address: address, ssn: ssn, birthDate: birthDate, description: "Contractor Employee, Project #\(project.rawValue)")
	}
}

class Vendor: VendorType, EntrantType, FullNameProvider, BirthdayProvider {
	
	let birthDate: NSDate?
	let vendorCompany: VendorCompany
	let accessibleAreas: [Area]
	let fullName: PersonFullName?
	let accessRules: RideAccess
	let description: String
	var visitDate: NSDate?
	
	init(company: VendorCompany, fullName: PersonFullName, birthDate: NSDate) throws {
		
		guard fullName.firstName != nil else {
			
			throw EntrantError.FirstNameMissing(message: "*********ERROR*********\rFirst Name Missing\r*********ERROR*********\n")
		}
		
		guard fullName.lastName != nil else {
			
			throw EntrantError.LastNameMissing(message: "*********ERROR*********\rLast Name Missing\r*********ERROR*********\n")
		}
		
		self.birthDate = birthDate
		self.vendorCompany = company
		self.accessibleAreas = AreaAccessByVendor[company] ?? []
		self.fullName = fullName
		self.accessRules = RideAccess(unlimitedAccess: false, skipLines: false, seeEntrantAccessRules: true)
		
		let dateString: String// = "\(visitDate ?? "never")"
		
		if let visitDate = visitDate {
			
			dateString = "\(visitDate)"
			
		} else {
			
			dateString = "Never"
		}
		
		self.description = "Vendor representative of: \(company.rawValue), Visit date: \(dateString)"
	}
	
	func swipe() -> EntryRules {
		
		self.visitDate = NSDate()
		
		let greeting = Aux.composeGreetingConsidering(birthDate, forEntrant: fullName)
		
		return EntryRules(areaAccess: accessibleAreas, rideAccess: accessRules, discountAccess: nil, greeting: greeting)
	}
	
}