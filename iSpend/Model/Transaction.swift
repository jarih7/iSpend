//
//  Transaction.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 06/12/2020.
//

import Foundation

struct Transaction {
    var counterparty: String
    var date: Date
    var id: Int
    var incoming: Bool
    var latitude: Double
    var longitude: Double
    var title: String
    var total: Double
    
    func locationEnabled() -> Bool {
        return (latitude == 0 && longitude == 0) ? false : true
    }
}
