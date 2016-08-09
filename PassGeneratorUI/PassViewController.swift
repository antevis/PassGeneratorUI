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
	
	@IBOutlet weak var childAccessStack: UIStackView!
	
	@IBOutlet weak var testResultsLabel: UILabel!
	@IBOutlet weak var testPaneView: UIView!
	
	
	
	var entrant: EntrantType?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		if let entrant = entrant {
		
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
				}
			} else {
				
				foodDiscountLabel.text = " "
				merchDiscountLabel.text = " "
			}
		}
		
		badgeView.layer.cornerRadius = 5
		badgeView.layer.shadowColor = UIColor(red: 193/255.0, green: 186/255.0, blue: 196/255.0, alpha: 1.0).CGColor
		badgeView.layer.shadowOpacity = 1
		badgeView.layer.shadowOffset = CGSize(width: 0, height: 2)
		badgeView.layer.shadowRadius = 0
		
		punctureView.layer.cornerRadius = 5
		punctureView.layer.shadowColor = UIColor(red: 193/255.0, green: 186/255.0, blue: 196/255.0, alpha: 1.0).CGColor
		punctureView.layer.shadowOpacity = 1
		punctureView.layer.shadowOffset = CGSize(width: 0, height: -2)
		punctureView.layer.shadowRadius = 0
		
		
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
    

	@IBAction func createNewPass(sender: AnyObject) {
		
		dismissViewControllerAnimated(true, completion: nil)
		
//		if let entrantController = storyboard?.instantiateViewControllerWithIdentifier("entrantDataController") as? ViewController {
//			
//			presentViewController(entrantController, animated: true, completion: nil)
//		}
	}
	@IBAction func areaAccess(sender: AnyObject) {
		
		Aux.removeButtonsFrom(childAccessStack)
		
		for (tag, area) in Area.areaDictionary(){
			
			let button = Aux.composeButton(buttonText: area.rawValue, tag: tag, bgColor: UIColor.lightGrayColor(), titleColor: UIColor.grayColor())
			button.addTarget(self, action: .testAreaAccessTapped, forControlEvents: .TouchUpInside)
			
			childAccessStack.addArrangedSubview(button)
		}
		
		
	}
	
	@IBAction func rideAccess(sender: AnyObject) {
	}
	
	@IBAction func discountAccess(sender: AnyObject) {
	}
	
	func testAreaAccess(sender: UIButton!) {
		
		let rules = entrant?.swipe()
		
		let area = Area.areaDictionary()[sender.tag]
		
		if let rules = rules, let areaAccessTestResult = area?.testAccess(rules, makeSound: true) {
		
			testPaneView.backgroundColor = areaAccessTestResult.accessGranted ? UIColor.greenColor() : UIColor.redColor()
			
			testResultsLabel.text = "\(areaAccessTestResult.message) to \(area?.rawValue ?? "Area")"
		}
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

private extension Selector {
	
	//static let parentTapped = #selector(ViewController.fillChildStack(_:))
	
	static let testAreaAccessTapped = #selector(PassViewController.testAreaAccess(_:))
	
}

