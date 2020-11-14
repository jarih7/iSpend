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
    
    let db = Firestore.firestore()
    var nextTransactionIndex: Int = Int()
    let dateFormatter = DateFormatter()
    var currency: String = "CZK"
    
    var MIS: Int = Int()
    var MOS: Int = Int()
    var WIS: Int = Int()
    var WOS: Int = Int()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "d. MM. yyyy"
        
        monthView.setupView()
        weekView.setupView()
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
            
            MIS = data["LMI"] as! Int
            MOS = data["LMO"] as! Int
            WIS = data["LWI"] as! Int
            WOS = data["LWO"] as! Int
            
            monthView.monthInSum.text = MIS.description
            monthView.monthOutSum.text = MOS.description
            monthView.monthBalance.text = (MIS - MOS).description
            weekView.weekInSum.text = WIS.description
            weekView.weekOutSum.text = WOS.description
            weekView.weekBalance.text = (WIS - WOS).description
        }
    }
}

