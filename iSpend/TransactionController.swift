//
//  TransactionController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 03/11/2020.
//

import UIKit
import FirebaseDatabase

class TransactionController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var counterpartyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    
    let dbRef = Database.database().reference()
    
    var transTitle: String = "PLACEHOLDER"
    var transCounterparty: String = "PLACEHOLDER"
    var transId: Int = 0
    var transIncoming: Bool = false
    var transTotal: Double = 0.0
    var transDate: String = "PLACEHOLDER"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = transTitle
        counterpartyLabel.text = transCounterparty
        dateLabel.text = transDate
        priceLabel.text = String(format: "%.2f", transTotal)
        
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
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { (UIAlertAction) in
            print("EDIT ACTION SELECTED")
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [self] (UIAlertAction) in
            dbRef.child("transactions/\(transId)").removeValue()
            _ = navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            print("CANCEL ACTION SELECTED")
        }
        
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
