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
    @IBOutlet weak var lastTransactionLabel: UILabel!
    @IBOutlet weak var lastTransactionView: LastTransactionView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        setupDateFormatter()
        monthView.setupView()
        weekView.setupView()
        lastTransactionView.setupView()
        DataManagement.sharedInstance.updateOveriewData = updateOveriewData
    }
    
    func updateOveriewData() {
        print("UPDATE OVERVIEW DATA")
        updateOverviewBlocks()
        updateLastTransaction()
    }
    
    func updateOverviewBlocks() {
        monthView.fromDate.text = dateFormatter.string(from: DataManagement.sharedInstance.LMFromDate)
        monthView.toDate.text = dateFormatter.string(from: Date())
        
        monthView.monthInSum.text = Int(DataManagement.sharedInstance.LMI).description
        monthView.monthOutSum.text = Int(DataManagement.sharedInstance.LMO).description
        monthView.monthBalance.text = (DataManagement.sharedInstance.LMI - DataManagement.sharedInstance.LMO) < 0 ? Int(DataManagement.sharedInstance.LMI - DataManagement.sharedInstance.LMO).description : "+" + Int(DataManagement.sharedInstance.LMI - DataManagement.sharedInstance.LMO).description
        
        weekView.weekInSum.text = Int(DataManagement.sharedInstance.LWI).description
        weekView.weekOutSum.text = Int(DataManagement.sharedInstance.LWO).description
        weekView.weekBalance.text = (DataManagement.sharedInstance.LWI - DataManagement.sharedInstance.LWO) < 0 ? Int(DataManagement.sharedInstance.LWI - DataManagement.sharedInstance.LWO).description : "+" + Int(DataManagement.sharedInstance.LWI - DataManagement.sharedInstance.LWO).description
    }
    
    func updateLastTransaction() {
        if (!DataManagement.sharedInstance.transactions.isEmpty) {
            lastTransactionView.isHidden = false
            lastTransactionLabel.isHidden = false
            prepareLastTransactionBlock()
        } else {
            //no transactions
            print("NO LAST ITEM")
            lastTransactionView.isHidden = true
            lastTransactionLabel.isHidden = true
        }
    }
    
    func prepareLastTransactionBlock() {
        lastTransactionView.ltTitle.text = DataManagement.sharedInstance.transactions.first?.title ?? "EMPTY"
        lastTransactionView.ltTotal.text = Int(DataManagement.sharedInstance.transactions.first?.total ?? 0).description
        
        if (DataManagement.sharedInstance.transactions.first?.incoming == true) {
            lastTransactionView.ltIncomingSymbol.text = "→"
            lastTransactionView.ltIncomingSymbol.textColor = .systemGreen
        } else {
            lastTransactionView.ltIncomingSymbol.text = "←"
            lastTransactionView.ltIncomingSymbol.textColor = .systemOrange
        }
        
        if (DataManagement.sharedInstance.transactions.first?.locationEnabled() == true) {
            lastTransactionView.locationBadge.isHidden = false
        } else {
            lastTransactionView.locationBadge.isHidden = true
        }
        
        lastTransactionView.ltCounterparty.text = DataManagement.sharedInstance.transactions.first?.counterparty ?? "EMPTY"
        lastTransactionView.ltDate.text = dateFormatter.string(from: DataManagement.sharedInstance.transactions.first?.date ?? Date())
    }
    
    func setupDateFormatter() {
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "d. M. yyyy"
    }
    
    @IBAction func lastTransactionTapped(_ sender: LastTransactionView) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let transactionVC = storyBoard.instantiateViewController(identifier: "TransactionController") as! TransactionController
        transactionVC.transId = DataManagement.sharedInstance.transactions.first!.id
        transactionVC.isQuickView = true
        present(transactionVC, animated: true, completion: nil)
    }
}
