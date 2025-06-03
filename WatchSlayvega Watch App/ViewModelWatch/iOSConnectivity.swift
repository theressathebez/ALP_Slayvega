//
//  iOSConnectivity.swift
//  WatchSlayvega Watch App
//
//  Created by student on 03/06/25.
//
import WatchConnectivity
import Foundation

class iOSConnectivity: NSObject, WCSessionDelegate, ObservableObject {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
}
