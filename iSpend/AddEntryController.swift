//
//  AddEntryController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 29/10/2020.
//

import UIKit
import FirebaseDatabase

class AddEntryController: UIViewController {
    
    let dbRef = Database.database().reference()
    let transactionsPath = "user/transactions/"
    let newTransactionId = 2
    var newTransactionPath = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newTransactionPath = "\(transactionsPath)/\(newTransactionId)"
        
        addData(name: "counterparty", value: "Albert")
    }
    
    func addData(name: String, value: Any) {
        dbRef.child("\(newTransactionPath)/\(name)").setValue(value)
    }
}
