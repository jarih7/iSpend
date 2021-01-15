//
//  BaseProtocol.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 14/01/2021.
//

import Foundation
import FirebaseFirestore

protocol BaseProtocol: UIViewController {
    var db: Firestore { get set }
    var transactions: [Transaction] { get set }
    var changedValues: [String:Any] { get set }
    
    var dateComponentDays: DateComponents { get set }
    var dateComponentMonts: DateComponents { get set }
    
    var LMI: Double { get set }
    var LMO: Double { get set }
    var LWI: Double { get set }
    var LWO: Double { get set }
    
    var updatedLMI: Double { get set }
    var updatedLMO: Double { get set }
    var updatedLWI: Double { get set }
    var updatedLWO: Double { get set }
    
    var LMFromDate: Date { get set }
    var LMToDate: Date { get set }
    
    var updatedLMFromDate: Date { get set }
    var updatedLMToDate: Date { get set }
    
    func getUpdatedValues()
    func updateValues()
    func updateTotals()
}

extension BaseProtocol {
    func getUpdatedValues() {
        updatedLMI = 0.0
        updatedLMO = 0.0
        updatedLWI = 0.0
        updatedLWO = 0.0
        
        print("NUM OF TRANSACTIONS: \(transactions.count)")
        
        for item in transactions {
            if (item.date > Calendar.current.date(byAdding: dateComponentDays, to: Date())!) {
                print("AN ITEM GOING TO THE LAST WEEK AND MONTH")
                if (item.incoming == true) {
                    updatedLWI += item.total
                    updatedLMI += item.total
                } else {
                    updatedLWO += item.total
                    updatedLMO += item.total
                }
            } else if (item.date > Calendar.current.date(byAdding: dateComponentMonts, to: Date())!) {
                print("AN ITEM GOING TO THE LAST MONTH")
                if (item.incoming == true) {
                    updatedLMI += item.total
                } else {
                    updatedLMO += item.total
                }
                
                //get "from" and "to" dates
                if (item.date.compare(LMFromDate) == .orderedAscending) {
                    updatedLMFromDate = item.date
                }
                
                if (item.date.compare(LMToDate) == .orderedDescending) {
                    updatedLMToDate = item.date
                }
            }
        }
    }
    
    func updateValues() {
        if (updatedLMI != LMI) {
            changedValues["LMI"] = updatedLMI
        }
        
        if (updatedLMO != LMO) {
            changedValues["LMO"] = updatedLMO
        }
        
        if (updatedLWI != LWI) {
            changedValues["LWI"] = updatedLWI
        }
        
        if (updatedLWO != LWO) {
            changedValues["LWO"] = updatedLWO
        }
        
        if (updatedLMFromDate != LMFromDate) {
            changedValues["LMFD"] = updatedLMFromDate
        }
        
        if (updatedLMToDate != LMToDate) {
            changedValues["LMTD"] = updatedLMToDate
        }
    }
    
    func updateTotals() {
        print("UPDATING TOTALS")
        
        getUpdatedValues()
        changedValues.removeAll()
        updateValues()
        
        if (!changedValues.isEmpty) {
            print("writing to firestore3")
            db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").updateData(changedValues)
        } else {
            print("NO CHANGES 1")
        }
    }
}
