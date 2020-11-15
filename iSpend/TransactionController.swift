//
//  TransactionController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 03/11/2020.
//

import UIKit
import FirebaseFirestore

class TransactionController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var counterpartyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    
    let db = Firestore.firestore()
    
    var transTitle: String = "PLACEHOLDER"
    var transCounterparty: String = "PLACEHOLDER"
    var transId: Int = 0
    var transIncoming: Bool = false
    var transTotal: Double = 0.0
    var transDate: String = "PLACEHOLDER"
    let newTransactionIndexPath: String = "nextTransIndex"
    var currency: String = "CZK"
    
    let dateFormatter = DateFormatter()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "d. MM. yyyy"
        setNeedsStatusBarAppearanceUpdate()
        titleLabel.text = transTitle
        counterpartyLabel.text = transCounterparty
        dateLabel.text = transDate
        priceLabel.text = String(format: "%.2f", transTotal)
        priceLabel.font = UIFont.monospacedSystemFont(ofSize: 30, weight: .bold)
        
        if (transIncoming == true) {
            symbolLabel.text = "→"
            symbolLabel.textColor = .systemGreen
        } else {
            symbolLabel.text = "←"
            symbolLabel.textColor = .systemOrange
        }
    }
    
    @IBAction func optionsButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Actions", message: "What do you want to do with this Transaction?", preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { [self] (UIAlertAction) in
            print("EDIT ACTION SELECTED")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let addTC = storyboard.instantiateViewController(identifier: "AddTransactionController") as! AddTransactionController
            
            addTC.passedTitle = transTitle
            addTC.passedConterparty = transCounterparty
            addTC.passedTotal = String(format: "%.2f", transTotal)
            addTC.passedDate = dateFormatter.date(from: transDate)!
            addTC.passedIncoming = transIncoming
            addTC.passedUpdate = true
            
            self.show(addTC, sender: self)
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [self] (UIAlertAction) in
            db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").updateData(["transMap." + String(transId) : FieldValue.delete()])
            navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
