//
//  DataManagement.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 17/01/2021.
//

import Foundation
import FirebaseFirestore

final class DataManagement {
    static let sharedInstance = DataManagement()
    var ts: String = "*START*"
    var db = Firestore.firestore()
    var listener: ListenerRegistration? = nil
    var map: [String:Any] = [:]
    var procItem: [String:Any] = [:]
    var transactions: [Transaction] = []
    
    init() {
        ts = "INITIALIZED"
        startListening()
    }
    
    func startListening() {
        listener = db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").addSnapshotListener {
            [self] (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            map = data["transMap"] as! Dictionary<String, Any>
            transactions.removeAll()
            procItem = [:]
            
            for item in map {
                procItem = item.value as! [String:Any]
                transactions.append(Transaction(counterparty: procItem["counterparty"] as? String ?? "COUNTERPARTY ERROR", date: Date(timeIntervalSince1970: TimeInterval((procItem["date"] as! Timestamp).seconds)), id: procItem["id"] as? Int ?? 999999, incoming: procItem["incoming"] as? Bool ?? false, latitude: (procItem["location"] as! GeoPoint).latitude, longitude: (procItem["location"] as! GeoPoint).longitude, title: procItem["title"] as? String ?? "TITLE ERROR", total: procItem["total"] as? Double ?? 123.45))
            }
            
            print("DM DATA UPDATED")
            print("TRANSACTIONS COUNT: \(transactions.count)")
        }
    }
}
