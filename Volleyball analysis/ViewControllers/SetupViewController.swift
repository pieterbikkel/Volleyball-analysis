//
//  SetupViewController.swift
//  Volleyball analysis
//
//  Created by Pieter Bikkel on 15/09/2023.
//

import UIKit

class SetupViewController: UIViewController {
    
    private let appManager = AppManager.shared
    
    override func viewDidLoad() {
        print("SetupViewController loaded 🔥")
        self.appManager.stateMachine.enter(AppManager.DetectingPlayerState.self)
    }
}

extension SetupViewController: AppStateChangeObserver {
    func appManagerDidEnter(state: AppManager.State, from previousState: AppManager.State?) {

        switch state {
        case is AppManager.SetupCameraState:
            print("Go to DetectingPlayerState")
            self.appManager.stateMachine.enter(AppManager.DetectingPlayerState.self)
        default:
            break
        }
    }
}
