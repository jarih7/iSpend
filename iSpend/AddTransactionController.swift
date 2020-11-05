//
//  AddTransactionController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 29/10/2020.
//

import UIKit
import FirebaseDatabase

class AddTransactionController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var counterpartyTextField: UITextField!
    @IBOutlet weak var totalTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var incomingSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    
    let dbRef = Database.database().reference()
    let transactionsPath: String = "transactions"
    let newTransactionIndexPath: String = "nextTransIndex"
    var newTransactionId = Int()
    var newTransactionPath: String = ""
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .medium
        
        dbRef.child(newTransactionIndexPath).observe(.value) { [self] (snapshot) in
            newTransactionId = snapshot.value as! Int
            newTransactionPath = "\(transactionsPath)/\(newTransactionId)"
            print("NEW TRANSACTION ID UPDATED TO: \(newTransactionId)")
        }
        
        setupFunctionality()
        setupStyle()
    }
    
    func setupFunctionality() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        titleTextField.delegate = self
        counterpartyTextField.delegate = self
        totalTextField.delegate = self
    }
    
    func setupStyle() {
        totalTextField.keyboardType = UIKeyboardType.numbersAndPunctuation
        incomingSwitch.isOn = false
        saveButton.backgroundColor = .systemBlue
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 5
    }
    
    func resetFields() {
        titleTextField.text = ""
        counterpartyTextField.text = ""
        totalTextField.text = ""
        datePicker.date = Date()
        incomingSwitch.isOn = false
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        //CHECK IF ALL NECESARY DATA WAS RECEIVED!
        
        let newTransaction: NSDictionary = [
            "counterparty": counterpartyTextField.text ?? "*EMPTY*",
            "date": dateFormatter.string(from: datePicker.date),
            "id": newTransactionId,
            "incoming": incomingSwitch.isOn,
            "title": titleTextField.text ?? "*EMPTY*",
            "total": Double(totalTextField.text!)!
        ]
        
        print("UPLOADING TRNSACTION DATA")
        dbRef.child(newTransactionPath).setValue(newTransaction)
        
        //finally update newTransIndex
        print("UPDATING TRANSACTIONID TO: \(newTransactionId + 1)")
        dbRef.child(newTransactionIndexPath).setValue(newTransactionId + 1)
        tabBarController?.selectedIndex = 2
        resetFields()
    }
}
