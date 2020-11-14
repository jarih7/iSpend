//
//  AddTransactionController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 29/10/2020.
//

import UIKit
import FirebaseFirestore

class AddTransactionController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var counterpartyTextField: UITextField!
    @IBOutlet weak var totalTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var incomingSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    
    let db = Firestore.firestore()
    let transactionsPath: String = "transMap"
    let newTransactionIndexPath: String = "nextTransIndex"
    var newTransactionIndex = Int()
    var newTransactionPath: String = ""
    let dateFormatter = DateFormatter()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "d. MM. yyyy"
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        
        db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").addSnapshotListener { [self] (documentSnapshot, error) in
            
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            newTransactionIndex = data["nextTransactionIndex"] as! Int
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
        titleTextField.textColor = .black
        counterpartyTextField.textColor = .black
        totalTextField.textColor = .black
        
        totalTextField.keyboardType = UIKeyboardType.numbersAndPunctuation
        incomingSwitch.isOn = false
        incomingSwitch.tintColor = .systemOrange
        incomingSwitch.layer.cornerRadius = incomingSwitch.frame.height / 2
        incomingSwitch.backgroundColor = .systemOrange
        
        saveButton.backgroundColor = UIColor(red: 68/255, green: 114/255, blue: 197/255, alpha: 1)
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 8
        datePicker.backgroundColor = .systemBackground
        datePicker.layer.cornerRadius = 8
        datePicker.layer.masksToBounds = true
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
            "date": datePicker.date,
            "id": newTransactionIndex,
            "incoming": incomingSwitch.isOn,
            "title": titleTextField.text ?? "*EMPTY*",
            "total": Double(totalTextField.text!)!
        ]
        
        db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").updateData(["transMap." + String(newTransactionIndex) : newTransaction])
        db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").updateData(["nextTransactionIndex" : newTransactionIndex + 1])
        
        tabBarController?.selectedIndex = 1
        resetFields()
    }
}
