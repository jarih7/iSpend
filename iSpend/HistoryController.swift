//
//  HistoryController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 29/10/2020.
//

import UIKit
import FirebaseFirestore

struct Transaction {
    var counterparty: String
    var date: Date
    var id: Int
    var incoming: Bool
    var title: String
    var total: Double
}

class HistoryController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var transactionsCollectionView: UICollectionView!
    
    let db = Firestore.firestore()
    var transactions: Array<Transaction> = []
    var nextTransactionIndex: Int = 999
    let dateFormatter = DateFormatter()
    var dateComponentDays = DateComponents()
    var dateComponentMonts = DateComponents()
    var currency: String = "CZK"
    
    var LMI: Double = Double()
    var LMO: Double = Double()
    var LWI: Double = Double()
    var LWO: Double = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionsCollectionView.automaticallyAdjustsScrollIndicatorInsets = true
        transactionsCollectionView.delegate = self
        transactionsCollectionView.dataSource = self
        setupDateFormatter()
        startListening()
    }
    
    func startListening() {
        db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").addSnapshotListener { [self] (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            nextTransactionIndex = data["nextTransactionIndex"] as! Int
            let map = data["transMap"] as! Dictionary<String, Any>
            var procItem: [String:Any] = [:]
            
            transactions.removeAll()
            for item in map {
                procItem = item.value as! [String : Any]
                transactions.append(Transaction(counterparty: procItem["counterparty"] as? String ?? "COUNTERPARTY ERROR", date: Date(timeIntervalSince1970: TimeInterval((procItem["date"] as! Timestamp).seconds)), id: procItem["id"] as? Int ?? 999999, incoming: procItem["incoming"] as? Bool ?? false, title: procItem["title"] as? String ?? "TITLE ERROR", total: procItem["total"] as? Double ?? 123.45))
            }
            
            transactions.sort { (tr1, tr2) -> Bool in
                tr1.date.compare(tr2.date) == .orderedDescending ? true : false
            }
            
            updateTotals()
            transactionsCollectionView.reloadData()
        }
    }
    
    func updateTotals() {
        dateComponentDays.day = -7
        dateComponentMonts.month = -1
        
        LMI = 0.0
        LMO = 0.0
        LWI = 0.0
        LWO = 0.0
        
        for item in transactions {
            if (item.date > Calendar.current.date(byAdding: dateComponentDays, to: Date())!) {
                if (item.incoming == true) {
                    LWI += item.total
                    LMI += item.total
                } else {
                    LWO += item.total
                    LMO += item.total
                }
            } else if (item.date > Calendar.current.date(byAdding: dateComponentMonts, to: Date())!) {
                if (item.incoming == true) {
                    LMI += item.total
                } else {
                    LMO += item.total
                }
            }
        }
        
        db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").updateData(["LMI" : LMI, "LMO" : LMO, "LWI" : LWI, "LWO" : LWO])
    }
    
    func setupDateFormatter() {
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "d. MM. yyyy"
    }
    
    func setupCellContent(cell: TransactionViewCell, transaction: Transaction) {
        cell.id = transaction.id
        cell.label.text = transaction.title
        cell.total.text = Int(transaction.total).description + " " + currency
        
        if (transaction.incoming == true) {
            cell.incoming = true
            cell.totalSymbol.text = "→"
        } else {
            cell.incoming = false
            cell.totalSymbol.text = "←"
        }
        
        cell.counterparty.text = transaction.counterparty
        cell.date.text = dateFormatter.string(from: transaction.date)
        cell.doubleTotalValue = transaction.total
    }
    
    func setupCellStyle(cell: TransactionViewCell, transaction: Transaction) {
        cell.backgroundColor = .systemBlue
        cell.layer.cornerRadius = 10
        cell.label.textColor = .white
        cell.total.textColor = .white
        
        if (transaction.incoming == true) {
            cell.totalSymbol.textColor = .green
        } else {
            cell.totalSymbol.textColor = .systemOrange
        }
        
        cell.counterparty.textColor = .white
        cell.date.textColor = .white
    }
    
    //----------------------------------------------------
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TransactionViewCell", for: indexPath) as! TransactionViewCell
        
        let transaction = transactions[indexPath.row] as Transaction
        setupCellContent(cell: cell, transaction: transaction)
        setupCellStyle(cell: cell, transaction: transaction)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: transactionsCollectionView.frame.width - 32, height: 100.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            cell.alpha = 1
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? TransactionViewCell {
            let vc = segue.destination as! TransactionController
            vc.transTitle = cell.label.text ?? "EMPTY"
            vc.transCounterparty = cell.counterparty.text ?? "EMPTY"
            vc.transId = cell.id
            vc.transIncoming = cell.incoming
            vc.transTotal = cell.doubleTotalValue
            vc.transDate = cell.date.text ?? "EMPTY"
        }
    }
    
    @IBAction func unwindToController(segue: UIStoryboardSegue) {
        
    }
}

