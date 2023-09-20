//
//  MyAppDelegate.swift
//  Volleyball analysis
//
//  Created by Pieter Bikkel on 15/09/2023.
//

import UIKit

class MyAppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Warmup Vision pipeline. This needs to be done just once.
        warmUpVisionPipeline()
        return true
    }
    
}
