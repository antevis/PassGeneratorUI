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
	
	var entrant: EntrantType?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		entrantNameLabel.text = entrant?.fullName?.firstName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
