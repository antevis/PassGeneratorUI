//
//  EntrantDataModel.swift
//  PassGeneratorUI
//
//  Created by Ivan Kazakov on 28/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import Foundation

enum EntrantCategory: String {
	
	case guest = "Guest"
	case employee = "Employee"
	case manager = "Manager"
	case vendor = "Vendor"
}

enum EntrantSubCategory: String {
	
	case classicGuest = "Classic Guest"
	case vipGuest = "VIP Guest"
	case freeChileGuest = "Free Child Guest"
	case hourlyEmployeeFood = "Food Services"
	case hourlyEmployeeRideServices = "Ride Services"
	case hourlyEmployeeMaintenance = "Maintenance"
	case shiftManager = "Shift Manager"
	case generalManager = "General Manager"
	case seniorManager = "Senior Manager"
	case seasonPassGuest = "Season Pass Guest"
	case seniorGuest = "Senior Guest"
	case contractEmployee = "Contract Employee"
	case vendorRepresentative = "Vendor Representative"
}

struct EntrantCat {
	
	let category: EntrantCategory
	
	let subCat: [(subCatName: EntrantSubCategory, entrantType: EntrantType.Type)]
}

let entrantStructure: [EntrantCat] = [

	EntrantCat(category: .employee, subCat: [
		(.hourlyEmployeeFood, HourlyEmployeeCatering.self),
		(.hourlyEmployeeMaintenance, HourlyEmployeeMaintenance.self),
		(.hourlyEmployeeRideServices, HourlyEmployeeRideService.self),
		(.contractEmployee, ContractEmployee.self)]),
	
	EntrantCat(category: .guest, subCat: [
		(.classicGuest, ClassicGuest.self),
		(.freeChileGuest, FreeChildGuest.self),
		(.seasonPassGuest, SeasonPassGuest.self),
		(.vipGuest, VipGuest.self),
		(.seniorGuest, SeniorGuest.self)]),
	
	EntrantCat(category: .manager, subCat: [
		(.shiftManager, Manager.self),
		(.generalManager, Manager.self),
		(.seniorManager, Manager.self)]),
	
	EntrantCat(category: .vendor, subCat: [(.vendorRepresentative, Vendor.self)])
	
]

