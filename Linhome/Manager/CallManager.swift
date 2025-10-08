//
//  CallManager.swift
//  Linhome
//
//  Created by Oscar Fernando Mora Gonzalez on 10/7/25.
//  Copyright © 2025 Belledonne communications. All rights reserved.
//

import Foundation

class CallManager {
    static let shared = CallManager()
    
    var isCallActive: Bool = false
    
    enum CallState {
        case none, connecting, active, ending
    }
    var callState: CallState = .none
    
    private init() {}
}

