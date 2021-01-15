//
//  ViewController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 28/10/2020.
//

import UIKit
import FirebaseFirestore

class OverviewController: UIViewController {
    @IBOutlet weak var monthView: MonthView!
    @IBOutlet weak var weekView: WeekView!
    @IBOutlet weak var lastTransactionView: LastTransactionView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let db = Firestore.firestore()
    var listener: ListenerRegistration? = nil
    var nextTransactionIndex: Int = Int()
    let dateFormatter = DateFormatter()
    var currency: String = "CZK"
    
    var LMI: Double = Double()
    var LMO: Double = Double()
    var LWI: Double = Double()
    var LWO: Double = Double()
    var LTId: Int = Int()
    
    var LMFromDate: Date = Date()
    var LMToDate: Date = Date()
    var lastTransaction: Transaction? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "d. M. yyyy"
        
        monthView.setupView()
        weekView.setupView()
        lastTransactionView.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("STARTED LISTENNING FROM OVERVIEW...")
        startListening()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("STOPPED LISTENNING FROM OVERVIEW...\n")
        listener?.remove()
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
            
            LMFromDate = Date(timeIntervalSince1970: TimeInterval((data["LMFD"] as! Timestamp).seconds))
            LMToDate = Date(timeIntervalSince1970: TimeInterval((data["LMTD"] as! Timestamp).seconds))
            
            //print("TEST LMI, LMO, LWI, LWO: \(LMI), \(LMO), \(LWI), \(LWO)")
            
            prepareOverviewBlocks()
            
            let map = data["transMap"] as! Dictionary<String, Any>
            if let transactionData = map[String(LTId)] as? [String : Any] {
                //print("ITEM IS THERE")
                lastTransactionView.isHidden = false
                
                lastTransaction = Transaction(counterparty: transactionData["counterparty"] as? String ?? "COUNTERPARTY ERROR", date: Date(timeIntervalSince1970: TimeInterval((transactionData["date"] as! Timestamp).seconds)), id: transactionData["id"] as? Int ?? 999999, incoming: transactionData["incoming"] as? Bool ?? false, latitude: (transactionData["location"] as! GeoPoint).latitude, longitude: (transactionData["location"] as! GeoPoint).longitude, title: transactionData["title"] as? String ?? "TITLE ERROR", total: transactionData["total"] as? Double ?? 123.45)
                
                prepareLastTransactionBlock()
            } else {
                //print("ITEM NOT THERE!")
                lastTransactionView.isHidden = true
            }
        }
    }
    
    func prepareOverviewBlocks() {
        monthView.fromDate.text = dateFormatter.string(from: LMFromDate)
        monthView.toDate.text = dateFormatter.string(from: LMToDate)
        
        monthView.monthInSum.text = Int(LMI).description
        monthView.monthOutSum.text = Int(LMO).description
        monthView.monthBalance.text = (LMI - LMO) < 0 ? Int(LMI - LMO).description : "+" + Int(LMI - LMO).description
        weekView.weekInSum.text = Int(LWI).description
        weekView.weekOutSum.text = Int(LWO).description
        weekView.weekBalance.text = (LWI - LWO) < 0 ? Int(LWI - LWO).description : "+" + Int(LWI - LWO).description
    }
    
    func prepareLastTransactionBlock() {
        lastTransactionView.ltTitle.text = lastTransaction?.title ?? "Title"
        lastTransactionView.ltTotal.text = Int(lastTransaction?.total ?? 0).description
        
        if (lastTransaction?.incoming == true) {
            lastTransactionView.ltIncomingSymbol.text = "→"
            lastTransactionView.ltIncomingSymbol.textColor = .systemGreen
        } else {
            lastTransactionView.ltIncomingSymbol.text = "←"
            lastTransactionView.ltIncomingSymbol.textColor = .systemOrange
        }
        
        if (lastTransaction?.locationEnabled() == true) {
            lastTransactionView.locationBadge.isHidden = false
        } else {
            lastTransactionView.locationBadge.isHidden = true
        }
        
        lastTransactionView.ltCounterparty.text = lastTransaction?.counterparty ?? "Counterparty title"
        lastTransactionView.ltDate.text = dateFormatter.string(from: lastTransaction?.date ?? Date())
    }
    
    @IBAction func lastTransactionTapped(_ sender: LastTransactionView) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let transactionVC = storyBoard.instantiateViewController(identifier: "TransactionController") as! TransactionController
        transactionVC.transId = lastTransaction!.id
        transactionVC.isQuickView = true
        present(transactionVC, animated: true, completion: nil)
    }
}

