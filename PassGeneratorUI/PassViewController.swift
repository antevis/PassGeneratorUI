//
//  PassViewController.swift
//  PassGeneratorUI
//
//  Created by Ivan Kazakov on 03/08/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import UIKit

class PassViewController: UIViewController {
	
	@IBOutlet weak var badgeView: UIView!
	@IBOutlet weak var entrantNameLabel: UILabel!
	@IBOutlet weak var passDescriptionLabel: UILabel!
	@IBOutlet weak var rideAccessLabel: UILabel!
	@IBOutlet weak var foodDiscountLabel: UILabel!
	@IBOutlet weak var merchDiscountLabel: UILabel!
	@IBOutlet weak var punctureView: UIView!
	@IBOutlet weak var parentStack: UIStackView!
	
	@IBOutlet weak var childAccessStack: UIStackView!
	
	@IBOutlet weak var testResultsLabel: UILabel!
	@IBOutlet weak var testPaneView: UIView!
	@IBOutlet weak var whiteShadowView: UIView!
	@IBOutlet weak var createNewPassButton: UIButton!
	
	let btnBackgroundColor = UIColor(red: 235/255.0, green: 231/255.0, blue: 238/255.0, alpha: 1.0)
	let btnTitleColor = UIColor(red: 72/255.0, green: 132/255.0, blue: 135/255.0, alpha: 1.0)
	let deniedColor = UIColor(red: 242/255.0, green: 0, blue: 61/255.0, alpha: 1)
	let grantedColor = UIColor(red: 0, green: 182/255.0, blue: 58/255.0, alpha: 1)
	let testPaneDefaultColor = UIColor(red: 191/255.0, green: 185/255.0, blue: 197/255.0, alpha: 1)
	let testPaneLabelDefaultColor = UIColor(red: 99/255.0, green: 94/255.0, blue: 102/255.0, alpha: 1)
	
	let cornerRadius: CGFloat = 5
	
	var entrant: EntrantType?
	
	var rules: EntryRules?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		if let entrant = entrant {
			
			self.rules = entrant.swipe()
			
			if let rules = rules {
			
				testResultsLabel.text = rules.greeting
			}
		
			badgeSetupFor(entrant)
		}
		
		shadowSetup()
		
		for subView in parentStack.subviews {
			
			if let button = subView as? UIButton {
				
				button.layer.cornerRadius = self.cornerRadius
			}
		}
    }

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	//MARK: Event Handlers
	@IBAction func createNewPass(sender: AnyObject) {
		
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	//Add area butons
	@IBAction func areaAccess(sender: AnyObject) {
		
		resetSubViews()
		
		for (tag, area) in Area.areaDictionary(){
			
			let button = Aux.composeButton(buttonText: area.rawValue, tag: tag, bgColor: btnBackgroundColor, titleColor: btnTitleColor, cornerRadius: self.cornerRadius)
			
			button.addTarget(self, action: .testAreaAccessTapped, forControlEvents: .TouchUpInside)
			
			childAccessStack.addArrangedSubview(button)
		}
	}
	
	//Add ride access buttons
	@IBAction func rideAccess(sender: AnyObject) {
		
		resetSubViews()
		
		if let rideAccessSpecs = rules?.rideAccess.rideAccessSpecification {
			
			for (specKey, specValue) in rideAccessSpecs {
				
				let button = Aux.composeButton(buttonText: specValue.description, tag: specKey, bgColor: btnBackgroundColor, titleColor: btnTitleColor, cornerRadius: self.cornerRadius)
				button.addTarget(self, action: Selector.testRideAccessTapped, forControlEvents: .TouchUpInside)
				
				childAccessStack.addArrangedSubview(button)
			}
		}
	}
	
	//add discount access buttons or info message in case of no discounts
	@IBAction func discountAccess(sender: AnyObject) {
		
		resetSubViews()
		
		if let discountRules = rules?.discountAccess where discountRules.count > 0 {
			
			for index in 0 ..< discountRules.count {
				
				let button = Aux.composeButton(buttonText: discountRules[index].subject.rawValue, tag: index, bgColor: btnBackgroundColor, titleColor: btnTitleColor, cornerRadius: self.cornerRadius)
				button.addTarget(self, action: Selector.testDiscountsTapped, forControlEvents: .TouchUpInside)
				
				childAccessStack.addArrangedSubview(button)
			}
			
		} else {
			
			childAccessStack.addArrangedSubview(Aux.createInfoLabelWith(message: "No discount data found.", labelColor: btnTitleColor))
			
			updateTestResultsPaneWith(false, text: (positive: "Yay", negative: "No discount data found."))
			
			Aux.playNegativeSound()
		}
		
	}
	
	
	func testAreaAccess(sender: UIButton!) {
		
		let area = Area.areaDictionary()[sender.tag]
		
		if let rules = rules, let areaAccessTestResult = area?.testAccess(rules, makeSound: true) {
		
			testPaneView.backgroundColor = areaAccessTestResult.accessGranted ? self.grantedColor : self.deniedColor
			testResultsLabel.text = "\(areaAccessTestResult.message) to \(area?.rawValue ?? "Area")"
			
			testResultsLabel.textColor = UIColor.whiteColor()
			
		}
	}
	
	func testRideAccess(sender: UIButton!) {
		
		if let rideAccessSpecs = rules?.rideAccess.rideAccessSpecification, let spec = rideAccessSpecs[sender.tag] {
			
			updateTestResultsPaneWith(spec.ruleValue, text: (positive: spec.positiveTitle, negative: spec.negativeTitle), makeSound: true)
			
		} else {
			updateTestResultsPaneWith(false, text: (positive: "Undefined Access", negative: "Undefined Access"), makeSound: true)
		}
	}
	
	func testDiscountAccess(sender: UIButton!) {
		
		if let discounts = rules?.discountAccess  {
			
			if sender.tag < discounts.count {
				
				let discountSpec = discounts[sender.tag]

				updateTestResultsPaneWith(true, text: (positive: discountSpec.description(), negative: discountSpec.description()), makeSound: true)
				
			} else { //Which is not supposed to ever happen but still
				
				updateTestResultsPaneWith(false, text: (positive: "Undefined Discount", negative: "Undefined Discount"), makeSound: true)
			}
		} else {
			
			updateTestResultsPaneWith(false, text: (positive: "No discounts found", negative: "No discounts found"), makeSound: true)
		}
	}
	
	//MARK: Auxilliary
	func shadowSetup() {
		
		badgeView.layer.cornerRadius = self.cornerRadius
		badgeView.layer.shadowColor = UIColor(red: 193/255.0, green: 186/255.0, blue: 196/255.0, alpha: 1.0).CGColor
		badgeView.layer.shadowOpacity = 1
		badgeView.layer.shadowOffset = CGSize(width: 0, height: 2)
		badgeView.layer.shadowRadius = 0
		
		punctureView.layer.cornerRadius = self.cornerRadius
		punctureView.layer.shadowColor = UIColor(red: 193/255.0, green: 186/255.0, blue: 196/255.0, alpha: 1.0).CGColor
		punctureView.layer.shadowOpacity = 1
		punctureView.layer.shadowOffset = CGSize(width: 0, height: -2)
		punctureView.layer.shadowRadius = 0
		
		testPaneView.layer.cornerRadius = self.cornerRadius
		testPaneView.layer.shadowColor = UIColor(red: 180/255.0, green: 173/255.0, blue: 184/255.0, alpha: 1.0).CGColor
		testPaneView.layer.shadowOpacity = 1
		testPaneView.layer.shadowOffset = CGSize(width: 0, height: -1)
		testPaneView.layer.shadowRadius = 0
		
		whiteShadowView.layer.cornerRadius = self.cornerRadius
		createNewPassButton.layer.cornerRadius = self.cornerRadius
	}
	
	func resetSubViews() {
		
		Aux.removeAllSubviewsFrom(childAccessStack)
		
		testPaneView.backgroundColor = self.testPaneDefaultColor
		testResultsLabel.text = "Test Results"
		testResultsLabel.textColor = testPaneLabelDefaultColor
	}
	
	
	func updateTestResultsPaneWith(result: Bool, text: (positive: String, negative: String), makeSound: Bool = false) {
		
		let sfx: SoundFX? = makeSound ? SoundFX() : nil
		
		var msg: String
		
		if result {
			
			sfx?.loadGrantedSound()
			msg = text.positive
		} else {
			
			sfx?.loadDeniedSound()
			msg = text.negative
		}
		
		testPaneView.backgroundColor = result ? self.grantedColor : self.deniedColor
		testResultsLabel.text = msg
		testResultsLabel.textColor = UIColor.whiteColor()
		
		sfx?.playSound()
		
	}
	
	func noDiscounts() {
		
		foodDiscountLabel.text = " "
		merchDiscountLabel.text = " "
	}
	
	func badgeSetupFor(entrant: EntrantType) {
		
		entrantNameLabel.text = "\(entrant.fullName?.firstName ?? "") \(entrant.fullName?.lastName ?? "")"
		passDescriptionLabel.text = entrant.description
		
		rideAccessLabel.text = entrant.accessRules.permissions()
		
		if let discountclaimantEntrant = entrant as? DiscountClaimant {
			
			let discounts = discountclaimantEntrant.discounts
			
			if discounts.count > 0 {
				
				foodDiscountLabel.text = "• \(Int(discounts[0].discountValue))% Food Discount"
				
				//Kind of silly but we would't have more than 2
				if discounts.count > 1 {
					
					merchDiscountLabel.text = "• \(Int(discounts[1].discountValue))% Merch Discount"
				}
				
			} else {
				
				//This workaround for ContractEmployee: it inherits DiscountClaimant protocol from Employee, but it's actually not.
				//Really no wish to refactor there anymore..
				noDiscounts()
			}
			
		} else {
			
			noDiscounts()
		}
	}
}

private extension Selector {
	
	static let testAreaAccessTapped = #selector(PassViewController.testAreaAccess(_:))
	static let testRideAccessTapped = #selector(PassViewController.testRideAccess(_:))
	static let testDiscountsTapped = #selector(PassViewController.testDiscountAccess(_:))
	
}

