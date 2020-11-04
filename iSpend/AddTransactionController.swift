//
//  AddTransactionController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 29/10/2020.
//

import UIKit
import FirebaseDatabase

class AddTransactionController: UIViewController {
    
    @IBOutlet weak var newTitle: UITextField!
    @IBOutlet weak var newCounterparty: UITextField!
    @IBOutlet weak var newTotal: UITextField!
    @IBOutlet weak var newDate: UIDatePicker!
    @IBOutlet weak var newIncoming: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    
    let transactionsPath = "user/transactions/"
    let NTIndexPath = "nextTransIndex"
    let dbRef = Database.database().reference()
    var newTransactionId = Int()
    var newTransactionPath = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        
        dbRef.child(NTIndexPath).observe(.value) { [self] (snapshot) in
            newTransactionId = snapshot.value as! Int
        }
        
        newTransactionPath = "\(transactionsPath)/\(newTransactionId)"
        //addData(name: "counterparty", value: "Albert")
    }
    
    func setupStyle() {
        saveButton.backgroundColor = .systemBlue
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 5
    }
    
    func addData(name: String, value: Any) {
        //dbRef.child("\(newTransactionPath)/\(name)").setValue(value)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
    }
}
