//
//  AppManager.swift
//  Volleyball analysis
//
//  Created by Pieter Bikkel on 15/09/2023.
//
/*
Abstract:
This class manages the app state.
*/

import GameKit

class AppManager {
    
    class State: GKState {
        private (set) var validNextStates: [State.Type]
        
        init(_ validNextStates: [State.Type]) {
            self.validNextStates = validNextStates
            super.init()
        }
        
        func addValidNextState(_ state: State.Type) {
            validNextStates.append(state)
        }
        
        override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            return validNextStates.contains(where: { stateClass == $0 })
        }
        
        override func didEnter(from previousState: GKState?) {
            let note = AppStateChangeNotification(newState: self, previousState: previousState as? State)
            note.post()
        }
    }
    
    class InactiveState: State {
    }
    
    class SetupCameraState: State {
    }
    
    class DetectingPlayerState: State {
    }
    
    class DetectedPlayerState: State {
    }
    
    class ProjectSkeletonState: State {
        
    }
    
    class ShowResultsState: State {
    }
    
    fileprivate var activeObservers = [UIViewController: NSObjectProtocol]()
    
    let stateMachine: GKStateMachine
    var recordedVideoSource: AVAsset?
    var playerStats = PlayerStats()
    
    static var shared = AppManager()
    
    private init() {
        // Possible states with valid next states
        let states = [
            InactiveState([SetupCameraState.self]),
            SetupCameraState([DetectingPlayerState.self]),
            DetectingPlayerState([DetectedPlayerState.self]),
            DetectedPlayerState([ProjectSkeletonState.self]),
            ProjectSkeletonState([ShowResultsState.self])
        ]
        // Any state besides Inactive can be returned to Inactive
        for state in states where !(state is InactiveState) {
            state.addValidNextState(InactiveState.self)
        }
        stateMachine = GKStateMachine(states: states)
    }
    
    func reset() {
        // Reset all stored values
        recordedVideoSource = nil
        // Remove all observers and enter inactive state.
        let notificationCenter = NotificationCenter.default
        for observer in activeObservers {
            notificationCenter.removeObserver(observer)
        }
        activeObservers.removeAll()
        stateMachine.enter(InactiveState.self)
    }
    
}

protocol AppStateChangeObserver: AnyObject {
    func appManagerDidEnter(state: AppManager.State, from previousState: AppManager.State?)
}

extension AppStateChangeObserver where Self: UIViewController {
    func startObservingStateChanges() {
        let token = NotificationCenter.default.addObserver(forName: AppStateChangeNotification.name, object: AppStateChangeNotification.object, queue: nil) { [weak self] notification in
            guard let note = AppStateChangeNotification(notification: notification) else { return }
            self?.appManagerDidEnter(state: note.newState, from: note.previousState)
        }
        let appManager = AppManager.shared
        appManager.activeObservers[self] = token
    }
    
    func stopObservingStateChanges() {
        let appManager = AppManager.shared
        guard let token = appManager.activeObservers[self] else {
            return
        }
        NotificationCenter.default.removeObserver(token)
        appManager.activeObservers.removeValue(forKey: self)
    }
}

struct AppStateChangeNotification {
    static let name = NSNotification.Name("AppStateChangeNotification")
    static let object = AppManager.shared
    
    let newStateKey = "newState"
    let previousStateKey = "previousState"

    let newState: AppManager.State
    let previousState: AppManager.State?
    
    init(newState: AppManager.State, previousState: AppManager.State?) {
        self.newState = newState
        self.previousState = previousState
    }
    
    init?(notification: Notification) {
        guard notification.name == Self.name, let newState = notification.userInfo?[newStateKey] as? AppManager.State else {
            return nil
        }
        self.newState = newState
        self.previousState = notification.userInfo?[previousStateKey] as? AppManager.State
    }
    
    func post() {
        var userInfo = [newStateKey: newState]
        if let previousState = previousState {
            userInfo[previousStateKey] = previousState
        }
        NotificationCenter.default.post(name: Self.name, object: Self.object, userInfo: userInfo)
    }
}

typealias AppStateChangeObserverViewController = UIViewController & AppStateChangeObserver
