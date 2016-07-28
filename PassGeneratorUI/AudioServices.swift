//
//  AudioServices.swift
//  PassGenerator
//
//  Created by Ivan Kazakov on 14/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import AudioToolbox

class SoundFX {
	
	var gameSound: SystemSoundID = 0
	
	//MARK: Audioservices
	func loadGrantedSound() {
		
		AudioServicesCreateSystemSoundID(soundUrlFor(file: "AccessGranted", ofType: "wav"), &gameSound)
	}
	
	func loadDeniedSound() {
		
		AudioServicesCreateSystemSoundID(soundUrlFor(file: "AccessDenied", ofType: "wav"), &gameSound)
	}
	
	func playSound(){
		
		AudioServicesPlaySystemSound(gameSound)
	}
	
	func soundUrlFor(file fileName: String, ofType: String) -> NSURL {
		
		let pathToSoundFile = NSBundle.mainBundle().pathForResource(fileName, ofType: ofType)
		return NSURL(fileURLWithPath: pathToSoundFile!)
	}
}
