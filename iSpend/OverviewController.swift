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
    
    var MIS: Double = Double()
    var MOS: Double = Double()
    var WIS: Double = Double()
    var WOS: Double = Double()
    
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
            
            MIS = data["LMI"] as! Double
            MOS = data["LMO"] as! Double
            WIS = data["LWI"] as! Double
            WOS = data["LWO"] as! Double
            
            monthView.monthInSum.text = Int(MIS).description
            monthView.monthOutSum.text = Int(MOS).description
            monthView.monthBalance.text = (MIS - MOS) < 0 ? Int(MIS - MOS).description : "+" + Int(MIS - MOS).description
            weekView.weekInSum.text = Int(WIS).description
            weekView.weekOutSum.text = Int(WOS).description
            weekView.weekBalance.text = (WIS - WOS) < 0 ? Int(WIS - WOS).description : "+" + Int(WIS - WOS).description
        }
    }
}

