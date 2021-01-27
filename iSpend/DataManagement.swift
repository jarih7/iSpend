//
//  DataManagement.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 17/01/2021.
//

struct Currency {
    var buttonImage: String
    var title: String
    var value: Double
}

struct Response: Decodable {
    let base: String
    let date: String
    let rates: Dictionary<String, Double>
}

import UIKit
import FirebaseFirestore

final class DataManagement {
    static let sharedInstance = DataManagement()
    
    var db = Firestore.firestore()
    var mainListener: ListenerRegistration? = nil
    var metadataListener: ListenerRegistration? = nil
    var currency: String = "CZK"
    var defaultIsIncoming: Bool = false
    
    var map: [String:Any] = [:]
    var procItem: [String:Any] = [:]
    var changedValues: [String:Any] = [:]
    
    var presentedTransaction: Transaction? = nil
    var updatedTransactions: [Transaction] = []
    
    var currenciesLastUpdated: Date = Date()
    var currencies: [Currency] = []
    var lastWeekTransactions: [Transaction] = []
    var lastMonthTransactions: [Transaction] = []
    
    var transactions: [Transaction] = [] {
        didSet {
            print("--- DID SET ---")
            DispatchQueue.main.async { [self] in
                updateOverviewData?()
                updateHistoryData?()
                updateTransactionDetailData?(false)
            }
        }
    }
    
    var usdVal: Double = Double()
    var eurVal: Double = Double()
    var gbpVal: Double = Double()
    var jpyVal: Double = Double()
    
    var LMI: Double = 0
    var LMO: Double = 0
    var LWI: Double = 0
    var LWO: Double = 0
    var LTId: Int = Int()
    var nextTransactionIndex = Int()
    var LMFromDate: Date = Date()
    var LMToDate: Date = Date()
    
    var dateComponentDays = DateComponents()
    var dateComponentMonts = DateComponents()
    
    init() {
        dateComponentDays.day = -7
        dateComponentMonts.month = -1
        fillCurrencies()
        startListening()
    }
    
    deinit {
        metadataListener?.remove()
        mainListener?.remove()
    }
    
    func getERData() {
        if let url = URL(string: "https://api.exchangeratesapi.io/latest?symbols=EUR,USD,GBP,JPY&base=CZK") {
            URLSession.shared.dataTask(with: url) { [self]
                data, response, error in
                if let data = data {
                    let jd = JSONDecoder()
                    do {
                        let parsed = try jd.decode(Response.self, from: data)
                        eurVal = 1 / parsed.rates["EUR"]!
                        usdVal = 1 / parsed.rates["USD"]!
                        gbpVal = 1 / parsed.rates["GBP"]!
                        jpyVal = 1 / parsed.rates["JPY"]!
                        
                        currencies[0].value = eurVal
                        currencies[1].value = usdVal
                        currencies[2].value = gbpVal
                        currencies[3].value = jpyVal
                        
                        currenciesLastUpdated = Date()
                    } catch let error {
                        print("AN ERROR OCCURED GETTING ER DATA: \(error)")
                    }
                }
            }.resume()
        }
    }
    
    func fillCurrencies() {
        getERData()
        currencies.append(Currency(buttonImage: "eurosign.circle.fill", title: "EUR", value: eurVal))
        currencies.append(Currency(buttonImage: "dollarsign.circle.fill", title: "USD", value: usdVal))
        currencies.append(Currency(buttonImage: "sterlingsign.circle.fill", title: "GBP", value: gbpVal))
        currencies.append(Currency(buttonImage: "yensign.circle.fill", title: "JPY", value: jpyVal))
    }
    
    func addOrUpdateTransaction(transaction: NSDictionary, updating: Bool, nextIndex: Int) {
        changedValues = [:]
        changedValues["transMap." + (transaction["id"] as! Int).description] = transaction
        
        //print("SENDING ADD OR UPDATE TRANSACTION DATA REQUEST")
        db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").updateData(changedValues)
        //print("ADD OR UPDATE TRANSACTION DATA REQUEST SENT")
        
        changedValues = [:]
        updateMetadata()
        
        if (updating == false) {
            print("ADDING NEW TRANSACTION IN DMANAGER WITH ID: \(String(describing: transaction["id"])), NEXT ID IS: \(nextIndex)")
            changedValues["nextTransactionIndex"] = nextIndex
            changedValues["LTId"] = transaction["id"]
        }
        
        //print("SENDING ADD OR UPDATE METADATA REQUEST")
        db.collection("iSpend").document("3bvxdXdmwUKlVIiRZjTO").updateData(changedValues)
        //print("ADD OR UPDATE METADATA REQUEST SENT")
    }
    
    func getTransactionById(id: Int) {
        if let transaction = transactions.first(where: { $0.id == id }) {
            presentedTransaction = transaction
        }
    }
    
    func deleteTransactionById(id: Int) {
        updatedTransactions.removeAll(where: { $0.id == id })
        changedValues = [:]
        changedValues["transMap." + id.description] = FieldValue.delete()
        
        print("SENDING DELETE TRANSACTION REQUEST")
        db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").updateData(changedValues)
        print("DELETE TRANSACTION REQUEST SENT")
        
        //updateMetadata
        changedValues = [:]
        
        if (updatedTransactions.isEmpty) {
            changedValues["nextTransactionIndex"] = 0
        }
        
        updateMetadata()
        
        print("SENDING UPDATE METADATA REQUEST")
        db.collection("iSpend").document("3bvxdXdmwUKlVIiRZjTO").updateData(changedValues)
        print("UPDATE METADATA REQUEST SENT")
    }
    
    func updateMetadata() {
        changedValues["LTId"] = updatedTransactions.first?.id ?? -1
        //changedValues["LMFD"] = Calendar.current.date(byAdding: dateComponentMonts, to: Date())!
        //changedValues["LMTD"] = Date()
    }
    
    func updateDefaultTransactionType(to: Int) {
        changedValues = [:]
        changedValues["defIsIn"] = to == 0 ? true : false
        
        //print("SENDING UPDATE DEF TR TYPE REQUEST")
        db.collection("iSpend").document("3bvxdXdmwUKlVIiRZjTO").updateData(changedValues)
        //print("UPDATE DEF TR TYPE REQUEST SENT")
    }
    
    var updateOverviewData: (() -> Void)?
    var updateHistoryData: (() -> Void)?
    var updateTransactionDetailData: ((_ firstLoad: Bool) -> Void)?
    
    func startListening() {
        mainListener = db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").addSnapshotListener(includeMetadataChanges: false, listener: { [self] (documentSnapshot, error) in
            print("*** MAIN LISTENING ***")
            
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            map = data["transMap"] as! Dictionary<String, Any>
            updatedTransactions.removeAll()
            lastMonthTransactions.removeAll()
            lastWeekTransactions.removeAll()
            procItem = [:]
            
            LMI = 0
            LMO = 0
            LWI = 0
            LWO = 0
            
            for item in map {
                procItem = item.value as! [String:Any]
                let newTransaction: Transaction = Transaction(counterparty: procItem["counterparty"] as? String ?? "COUNTERPARTY ERROR", date: Date(timeIntervalSince1970: TimeInterval((procItem["date"] as! Timestamp).seconds)), id: procItem["id"] as? Int ?? 999999, incoming: procItem["incoming"] as? Bool ?? false, latitude: (procItem["location"] as! GeoPoint).latitude, longitude: (procItem["location"] as! GeoPoint).longitude, title: procItem["title"] as? String ?? "TITLE ERROR", total: procItem["total"] as? Double ?? 123.45)
                
                updatedTransactions.append(newTransaction)
                
                if (newTransaction.date > Calendar.current.date(byAdding: dateComponentDays, to: Date())!) {
                    //last week transaction
                    lastWeekTransactions.append(newTransaction)
                    lastMonthTransactions.append(newTransaction)
                    
                    if (newTransaction.incoming == true) {
                        LWI += newTransaction.total
                        LMI += newTransaction.total
                    } else {
                        LWO += newTransaction.total
                        LMO += newTransaction.total
                    }
                } else if (newTransaction.date > Calendar.current.date(byAdding: dateComponentMonts, to: Date())!) {
                    //last month transaction
                    lastMonthTransactions.append(newTransaction)
                    
                    if (newTransaction.incoming == true) {
                        LMI += newTransaction.total
                    } else {
                        LMO += newTransaction.total
                    }
                }
            }
            
            sortTransactions()
            //print("SETTING TRANSACTIONS ---")
            transactions = updatedTransactions
            //print("TRANSACTIONS SET ---")
        })
        
        metadataListener = db.collection("iSpend").document("3bvxdXdmwUKlVIiRZjTO").addSnapshotListener(includeMetadataChanges: false, listener: { [self] (documentSnapshot, error) in
            print("*** METADATA LISTENING ***")
            
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            LTId = data["LTId"] as! Int
            defaultIsIncoming = data["defIsIn"] as! Bool
            nextTransactionIndex = data["nextTransactionIndex"] as! Int
        })
    }
    
    func sortTransactions() {
        if (!updatedTransactions.isEmpty) {
            updatedTransactions.sort { (tr1, tr2) -> Bool in
                if (tr1.date.compare(tr2.date) == .orderedDescending) {
                    return true
                } else if (tr1.date.compare(tr2.date) == .orderedAscending) {
                    return false
                } else {
                    return tr1.id > tr2.id
                }
            }
        }
    }
}
