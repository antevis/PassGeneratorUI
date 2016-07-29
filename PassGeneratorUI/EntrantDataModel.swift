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
	
	let subCat: [EntrantSubCategory]
}

let entrantStructure: [EntrantCat] = [

	EntrantCat(category: .employee, subCat: [
		.hourlyEmployeeFood,
		.hourlyEmployeeMaintenance,
		.hourlyEmployeeRideServices,
		.contractEmployee]),
	
	EntrantCat(category: .guest, subCat: [
		.classicGuest,
		.freeChileGuest,
		.seasonPassGuest,
		.vipGuest]),
	
	EntrantCat(category: .manager, subCat: [
		.shiftManager,
		.generalManager,
		.seniorManager]),
	
	EntrantCat(category: .vendor, subCat: [.vendorRepresentative])
	
]

