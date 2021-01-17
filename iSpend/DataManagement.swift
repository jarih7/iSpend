//
//  DataManagement.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 17/01/2021.
//

import Foundation

final class DataManagement {
    static let sharedInstance = DataManagement()
    var ts: String = "*START*"
    
    init() {
        ts = "INITIALIZED"
    }
}
