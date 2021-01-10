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
    @IBOutlet weak var locationBadge: UIButton!
    
    let db = Firestore.firestore()
    var listener: ListenerRegistration? = nil
    var nextTransactionIndex: Int = Int()
    let dateFormatter = DateFormatter()
    var currency: String = "CZK"
    
    var MIS: Double = Double()
    var MOS: Double = Double()
    var WIS: Double = Double()
    var WOS: Double = Double()
    var LTId: Int = Int()
    var lastTransaction: Transaction? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "d. MM. yyyy"
        
        monthView.setupView()
        weekView.setupView()
        lastTransactionView.setupView()
        
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors =
            [UIColor.init(red: 32/255, green: 56/255, blue: 100/255, alpha: 1).cgColor,
             UIColor.init(red: 49/255, green: 87/255, blue: 149/255, alpha: 1).cgColor]
        view.layer.insertSublayer(gradient, at: 0)
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
            
            MIS = data["LMI"] as! Double
            MOS = data["LMO"] as! Double
            WIS = data["LWI"] as! Double
            WOS = data["LWO"] as! Double
            LTId = data["LTId"] as! Int
            
            prepareOverviewBlocks()
            
            let map = data["transMap"] as! Dictionary<String, Any>
            if let transactionData = map[String(LTId)] as? [String : Any] {
                print("ITEM IS THERE")
                lastTransactionView.isHidden = false
                locationBadge.isHidden = false
                lastTransaction = Transaction(counterparty: transactionData["counterparty"] as? String ?? "COUNTERPARTY ERROR", date: Date(timeIntervalSince1970: TimeInterval((transactionData["date"] as! Timestamp).seconds)), id: transactionData["id"] as? Int ?? 999999, incoming: transactionData["incoming"] as? Bool ?? false, latitude: (transactionData["location"] as! GeoPoint).latitude, longitude: (transactionData["location"] as! GeoPoint).longitude, title: transactionData["title"] as? String ?? "TITLE ERROR", total: transactionData["total"] as? Double ?? 123.45)
                
                prepareLastTransactionBlock()
            } else {
                print("ITEM NOT THERE!")
                lastTransactionView.isHidden = true
                locationBadge.isHidden = true
            }
        }
    }
    
    func prepareOverviewBlocks() {
        monthView.monthInSum.text = Int(MIS).description
        monthView.monthOutSum.text = Int(MOS).description
        monthView.monthBalance.text = (MIS - MOS) < 0 ? Int(MIS - MOS).description : "+" + Int(MIS - MOS).description
        weekView.weekInSum.text = Int(WIS).description
        weekView.weekOutSum.text = Int(WOS).description
        weekView.weekBalance.text = (WIS - WOS) < 0 ? Int(WIS - WOS).description : "+" + Int(WIS - WOS).description
    }
    
    func prepareLastTransactionBlock() {
        lastTransactionView.ltTitle.text = lastTransaction?.title
        lastTransactionView.ltTotal.text = Int(lastTransaction?.total ?? 0).description
        
        if (lastTransaction?.incoming == true) {
            lastTransactionView.ltIncomingSymbol.text = "→"
            lastTransactionView.ltIncomingSymbol.textColor = .systemGreen
        } else {
            lastTransactionView.ltIncomingSymbol.text = "←"
            lastTransactionView.ltIncomingSymbol.textColor = .systemOrange
        }
        
        lastTransactionView.ltCounterparty.text = lastTransaction?.counterparty
        lastTransactionView.ltDate.text = dateFormatter.string(from: lastTransaction?.date ?? Date())
        
        locationBadge.isHidden = (lastTransaction?.locationEnabled())! ? false : true
    }
    
    @IBAction func lastTransactionTapped(_ sender: LastTransactionView) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let transactionVC = storyBoard.instantiateViewController(identifier: "TransactionController") as! TransactionController
        transactionVC.transId = lastTransaction!.id
        transactionVC.isQuickView = true
        present(transactionVC, animated: true, completion: nil)
    }
}

