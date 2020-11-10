//
//  ViewController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 28/10/2020.
//

import UIKit
import FirebaseFirestore

class OverviewController: UIViewController {
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var lastMonthLabel: UILabel!
    @IBOutlet weak var monthInSymbol: UILabel!
    @IBOutlet weak var monthInSum: UILabel!
    @IBOutlet weak var monthOutSymbol: UILabel!
    @IBOutlet weak var monthOutSum: UILabel!
    @IBOutlet weak var monthBalanceLabel: UILabel!
    @IBOutlet weak var monthBalance: UILabel!
    
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var lastWeekLabel: UILabel!
    @IBOutlet weak var weekInSymbol: UILabel!
    @IBOutlet weak var weekInSum: UILabel!
    @IBOutlet weak var weekOutSymbol: UILabel!
    @IBOutlet weak var weekOutSum: UILabel!
    @IBOutlet weak var weekBalanceLabel: UILabel!
    @IBOutlet weak var weekBalance: UILabel!
    
    let db = Firestore.firestore()
    var nextTransactionIndex: Int = Int()
    let dateFormatter = DateFormatter()
    var currency: String = "CZK"
    
    var MIS: Int = Int()
    var MOS: Int = Int()
    var WIS: Int = Int()
    var WOS: Int = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "d. MM. yyyy"
        
        setupMonthView()
        setupWeekView()
        startListening()
    }
    
    func setupMonthView() {
        monthView.layer.backgroundColor = UIColor.systemBlue.cgColor
        monthView.layer.cornerRadius = 10
        lastMonthLabel.textColor = .white
        monthInSymbol.text = "→"
        monthOutSymbol.text = "←"
        monthInSymbol.textColor = .green
        monthOutSymbol.textColor = .systemOrange
        monthInSum.textColor = .white
        monthOutSum.textColor = .white
        monthBalance.textColor = .white
        monthBalanceLabel.textColor = .white
    }
    
    func setupWeekView() {
        weekView.layer.backgroundColor = UIColor.systemBlue.cgColor
        weekView.layer.cornerRadius = 10
        lastWeekLabel.textColor = .white
        weekInSymbol.text = "→"
        weekOutSymbol.text = "←"
        weekInSymbol.textColor = .green
        weekOutSymbol.textColor = .systemOrange
        weekInSum.textColor = .white
        weekOutSum.textColor = .white
        weekBalance.textColor = .white
        weekBalanceLabel.textColor = .white
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
            
            MIS = data["LMI"] as! Int
            MOS = data["LMO"] as! Int
            WIS = data["LWI"] as! Int
            WOS = data["LWO"] as! Int
            
            monthInSum.text = MIS.description + " " + currency
            monthOutSum.text = MOS.description + " " + currency
            weekInSum.text = WIS.description + " " + currency
            weekOutSum.text = WOS.description + " " + currency
            monthBalance.text = (MIS - MOS).description + " " + currency
            weekBalance.text = (WIS - WOS).description + " " + currency
        }
    }
}

