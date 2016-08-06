//
//  PassViewController.swift
//  PassGeneratorUI
//
//  Created by Ivan Kazakov on 03/08/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import UIKit

class PassViewController: UIViewController {
	
	@IBOutlet weak var entrantNameLabel: UILabel!
	@IBOutlet weak var passDescriptionLabel: UILabel!
	@IBOutlet weak var rideAccessLabel: UILabel!
	@IBOutlet weak var foodDiscountLabel: UILabel!
	@IBOutlet weak var merchDiscountLabel: UILabel!
	
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
					
					foodDiscountLabel.text = "\(Int(discounts[0].discountValue))% Food Discount"
					merchDiscountLabel.text = "\(Int(discounts[1].discountValue))% Merch Discount"
				}
			} else {
				
				foodDiscountLabel.text = " "
				merchDiscountLabel.text = " "
			}
		}
		
		
		
		
		
		
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
