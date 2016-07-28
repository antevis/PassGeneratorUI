//
//  ViewController.swift
//  PassGeneratorUI
//
//  Created by Ivan Kazakov on 28/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var headerStackView: UIStackView!
	@IBOutlet weak var subCatStackView: UIStackView!
	
	var headerButtons: [UIButton] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		var tag: Int = 0
		
		for item in entrantStructure {
			
			let button = UIButton()
			button.backgroundColor = UIColor.blueColor()
			button.setTitle(item.category.rawValue, forState: .Normal)
			button.setTitleColor(UIColor.grayColor(), forState: .Normal)
			button.titleLabel?.textAlignment = .Center
			button.titleLabel?.lineBreakMode = .ByWordWrapping
			button.addTarget(self, action: #selector(fillChildStack), forControlEvents: .TouchUpInside)
			
			button.tag = tag
			
			headerStackView.addArrangedSubview(button)
			
			headerButtons.append(button)
			
			tag += 1
		}
		
		if headerButtons.count > 0 {
			
			let button = headerButtons[0]
			
			button.sendActionsForControlEvents(.TouchUpInside)
		
			//fillChildStack(button)
		}
		
	}
	
	func fillChildStack(sender: UIButton!){
		
		for button in headerButtons {
			
			button.setTitleColor(UIColor.grayColor(), forState: .Normal)
		}
		
		sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		
		Aux.removeButtonsFrom(subCatStackView)
		
		let entrantStructureItem: EntrantCat = entrantStructure[sender.tag]
		
		var tag: Int = 0
		
		for item in entrantStructureItem.subCat {
			
			let button = UIButton()
			button.backgroundColor = UIColor.magentaColor()
			button.setTitle(item.rawValue, forState: .Normal)
			button.setTitleColor(UIColor.grayColor(), forState: .Normal)
			button.titleLabel?.textAlignment = .Center
			button.titleLabel?.lineBreakMode = .ByWordWrapping
			button.addTarget(self, action: #selector(onSubCatSelected), forControlEvents: .TouchUpInside)
			
			button.tag = tag
			
			subCatStackView.addArrangedSubview(button)
			
			tag += 1
		}
	}
	
	func onSubCatSelected(sender: UIButton!) {
		
		for subView in subCatStackView.subviews {
			
			if let button = subView as? UIButton {
				
				button.setTitleColor(UIColor.grayColor(), forState: .Normal)
			}
		}
		
		sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

