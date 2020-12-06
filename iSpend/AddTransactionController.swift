//
//  AddTransactionController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 29/10/2020.
//

import UIKit
import FirebaseFirestore

class AddTransactionController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var counterpartyTextField: UITextField!
    @IBOutlet weak var totalTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var incomingSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dismissButton: UIButton!
    
    var headerText: String = "New Transaction"
    
    let db = Firestore.firestore()
    let transactionsPath: String = "transMap"
    let newTransactionIndexPath: String = "nextTransIndex"
    var newTransactionIndex = Int()
    var newTransactionPath: String = ""
    let dateFormatter = DateFormatter()
    
    var passedIndex: Int = 0
    var passedTitle: String = ""
    var passedConterparty: String = ""
    var passedTotal: String = ""
    var passedDate: Date = Date()
    var passedIncoming: Bool = false
    var passedUpdate: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "d. MM. yyyy"
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        
        if (passedUpdate == false) {
            dismissButton.isHidden = true
        } else {
            dismissButton.isHidden = false
        }
        
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
        setupContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func setupFunctionality() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        titleTextField.delegate = self
        counterpartyTextField.delegate = self
        totalTextField.delegate = self
    }
    
    func setupStyle() {
        titleTextField.textColor = .white
        counterpartyTextField.textColor = .white
        totalTextField.textColor = .white
        
        titleTextField.layer.cornerRadius = 10.0
        counterpartyTextField.layer.cornerRadius = 10.0
        totalTextField.layer.cornerRadius = 10.0
        
        titleTextField.layer.masksToBounds = true
        counterpartyTextField.layer.masksToBounds = true
        totalTextField.layer.masksToBounds = true
        
        titleTextField.attributedPlaceholder = NSAttributedString(string: "enter transaction's title", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightText])
        counterpartyTextField.attributedPlaceholder = NSAttributedString(string: "enter counterparty's name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightText])
        totalTextField.attributedPlaceholder = NSAttributedString(string: "enter transaction's total", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightText])
        
        totalTextField.keyboardType = UIKeyboardType.numbersAndPunctuation
        incomingSwitch.isOn = false
        incomingSwitch.tintColor = .systemOrange
        incomingSwitch.layer.cornerRadius = incomingSwitch.frame.height / 2
        incomingSwitch.backgroundColor = .systemOrange
        
        saveButton.backgroundColor = UIColor(red: 68/255, green: 114/255, blue: 197/255, alpha: 1)
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 8
        saveButton.layer.shadowColor = UIColor(red: 32/255, green: 56/255, blue: 100/255, alpha: 1).cgColor
        saveButton.layer.shadowOffset = CGSize(width: 3, height: 5)
        saveButton.layer.shadowRadius = 8
        saveButton.layer.shadowOpacity = 1
        
        datePicker.backgroundColor = .systemBackground
        datePicker.layer.cornerRadius = 8
        datePicker.layer.masksToBounds = true
    }
    
    func setupContent() {
        headerLabel.text = headerText
        titleTextField.text = passedTitle
        counterpartyTextField.text = passedConterparty
        totalTextField.text = passedTotal
        datePicker.date = passedDate
        incomingSwitch.isOn = passedIncoming
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
        let usingTransIndex = passedUpdate == false ? newTransactionIndex : passedIndex
        
        let newTransaction: NSDictionary = [
            "counterparty": counterpartyTextField.text ?? "*EMPTY*",
            "date": datePicker.date,
            "id": usingTransIndex,
            "incoming": incomingSwitch.isOn,
            "title": titleTextField.text ?? "*EMPTY*",
            "total": Double(totalTextField.text!)!
        ]
        
        db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").updateData(["transMap." + usingTransIndex.description : newTransaction])
        
        if (passedUpdate == false) {
            db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").updateData(["nextTransactionIndex" : newTransactionIndex + 1])
            tabBarController?.selectedIndex = 1
        } else {
            passedUpdate = false
            dismiss(animated: true, completion: nil)
        }
        
        headerLabel.text = "New Transaction"
        resetFields()
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
