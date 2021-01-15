//
//  HistoryController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 29/10/2020.
//

import UIKit
import FirebaseFirestore

class HistoryController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, BaseProtocol {
    
    @IBOutlet weak var transactionsCollectionView: UICollectionView!
    
    var db = Firestore.firestore()//
    var listener: ListenerRegistration? = nil//
    var transactions: [Transaction] = []//
    var changedValues: [String:Any] = [:]//
    
    let dateFormatter = DateFormatter()//
    var dateComponentDays = DateComponents()//
    var dateComponentMonts = DateComponents()//
    
    var currency: String = "CZK"//
    var nextTransactionIndex: Int = 999
    var LTId: Int = Int()//
    
    var LMI: Double = Double()//
    var LMO: Double = Double()//
    var LWI: Double = Double()//
    var LWO: Double = Double()//
    
    var updatedLMI: Double = Double()//
    var updatedLMO: Double = Double()//
    var updatedLWI: Double = Double()//
    var updatedLWO: Double = Double()//
    
    var LMFromDate: Date = Date()//
    var LMToDate: Date = Date()//
    
    var updatedLMFromDate: Date = Date()//
    var updatedLMToDate: Date = Date()//
    
    override func viewWillAppear(_ animated: Bool) {
        //print("STARTED LISTENNING FROM HISTORY...")
        //startListening()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        transactionsCollectionView.automaticallyAdjustsScrollIndicatorInsets = true
        transactionsCollectionView.delegate = self
        transactionsCollectionView.dataSource = self
        setupDateFormatter()
        
        startListening()
        print("STARTED LISTENNING FROM HISTORY...")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //print("STOPPED LISTENNING FROM HISTORY...\n")
        //listener?.remove()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        transactionsCollectionView.contentInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 16.0, right: 16.0)
    }
    
    func startListening() {
        listener = db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").addSnapshotListener { [self] (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            LMI = data["LMI"] as! Double
            LMO = data["LMO"] as! Double
            LWI = data["LWI"] as! Double
            LWO = data["LWO"] as! Double
            LTId = data["LTId"] as! Int
            nextTransactionIndex = data["nextTransactionIndex"] as! Int
            
            let map = data["transMap"] as! Dictionary<String, Any>
            var procItem: [String:Any] = [:]
            transactions.removeAll()
            
            for item in map {
                procItem = item.value as! [String : Any]
                transactions.append(Transaction(counterparty: procItem["counterparty"] as? String ?? "COUNTERPARTY ERROR", date: Date(timeIntervalSince1970: TimeInterval((procItem["date"] as! Timestamp).seconds)), id: procItem["id"] as? Int ?? 999999, incoming: procItem["incoming"] as? Bool ?? false, latitude: (procItem["location"] as! GeoPoint).latitude, longitude: (procItem["location"] as! GeoPoint).longitude, title: procItem["title"] as? String ?? "TITLE ERROR", total: procItem["total"] as? Double ?? 123.45))
            }
            
            if (!transactions.isEmpty) {
                print("SORTING TRANSACTIONS1")
                transactions.sort { (tr1, tr2) -> Bool in
                    if (tr1.date.compare(tr2.date) == .orderedDescending) {
                        return true
                    } else if (tr1.date.compare(tr2.date) == .orderedAscending) {
                        return false
                    } else {
                        return tr1.id > tr2.id
                    }
                }
            }
            
            if let lastTransaction: Transaction = transactions.first {
                let lastTransactionId: Int = lastTransaction.id
                if (LTId != lastTransactionId) {
                    //change happened that is not reflected in here yet
                    print("writing to firestore1")
                    db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").updateData(["LTId" : lastTransactionId])
                    updateTotals()
                }
            } else {
                print("NO TRANSACTIONS LEFT 2")
            }
            
            transactionsCollectionView.reloadData()
        }
    }
    
    func setupDateFormatter() {
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "d. M. yyyy"
        dateComponentDays.day = -7
        dateComponentMonts.month = -1
    }
    
    func setupCellContent(cell: TransactionViewCell, transaction: Transaction) {
        cell.id = transaction.id
        cell.label.text = transaction.title
        cell.total.text = Int(transaction.total).description
        
        if (transaction.incoming == true) {
            cell.incoming = true
            cell.totalSymbol.text = "→"
        } else {
            cell.incoming = false
            cell.totalSymbol.text = "←"
        }
        
        if (transaction.locationEnabled()) {
            cell.locationBadge.isHidden = false
        } else {
            cell.locationBadge.isHidden = true
        }
        
        cell.counterparty.text = transaction.counterparty
        cell.date.text = dateFormatter.string(from: transaction.date)
        cell.doubleTotalValue = transaction.total
    }
    
    //----------------------------------------------------
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TransactionViewCell", for: indexPath) as! TransactionViewCell
        
        let transaction = transactions[indexPath.row] as Transaction
        setupCellContent(cell: cell, transaction: transaction)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: transactionsCollectionView.frame.width - 32, height: 100.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: transactionsCollectionView.frame.width - 32, height: 90.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let historyViewHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? HistoryViewHeader {
            historyViewHeader.headerLabel.text = "History"
            historyViewHeader.headerLabel.textColor = .label
            historyViewHeader.headerLabel.font = UIFont.systemFont(ofSize: 45.0, weight: .heavy)
            return historyViewHeader
        }
        return UICollectionReusableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? TransactionViewCell {
            let vc = segue.destination as! TransactionController
            vc.transId = cell.id
        }
    }
    
    @IBAction func unwindToController(segue: UIStoryboardSegue) {
        
    }
}

