//
//  AddTransactionController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 29/10/2020.
//

import UIKit
import CoreLocation
import FirebaseFirestore

class AddTransactionController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var counterpartyTextField: UITextField!
    @IBOutlet weak var totalTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var incomingSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    var headerText: String = "New Transaction"
    
    let db = Firestore.firestore()
    let locationManager = CLLocationManager()
    var myLocation: GeoPoint = GeoPoint(latitude: 0, longitude: 0)
    
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
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
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
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    func setupFunctionality() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        locationButton.isSelected = myLocation == GeoPoint(latitude: 0, longitude: 0) ? false : true
        
        titleTextField.delegate = self
        counterpartyTextField.delegate = self
        totalTextField.delegate = self
    }
    
    func setupStyle() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors =
            [UIColor.init(red: 32/255, green: 56/255, blue: 100/255, alpha: 1).cgColor,
             UIColor.init(red: 49/255, green: 87/255, blue: 149/255, alpha: 1).cgColor]
        view.layer.insertSublayer(gradient, at: 0)
        
        locationButton.setImage(UIImage(systemName: "location.fill"), for: .selected)
        locationButton.setImage(UIImage(systemName: "location.slash.fill"), for: .normal)
        locationButton.tintColor = myLocation == GeoPoint(latitude: 0, longitude: 0) ? .lightText : .white
        
        titleTextField.textColor = .white
        counterpartyTextField.textColor = .white
        totalTextField.textColor = .white
        
        titleTextField.layer.cornerRadius = 7
        counterpartyTextField.layer.cornerRadius = 7
        totalTextField.layer.cornerRadius = 7
        
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
        saveButton.layer.cornerRadius = 7
        saveButton.layer.shadowColor = UIColor(red: 32/255, green: 56/255, blue: 100/255, alpha: 1).cgColor
        saveButton.layer.shadowOffset = CGSize(width: 2, height: 4)
        saveButton.layer.shadowRadius = 5
        saveButton.layer.shadowOpacity = 0.9
        
        datePicker.backgroundColor = .systemBackground
        datePicker.layer.cornerRadius = 7
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
        let usingTransIndex = passedUpdate == false ? newTransactionIndex : passedIndex
        let newTransaction: NSDictionary = [
            "counterparty": counterpartyTextField.text ?? "*EMPTY*",
            "date": datePicker.date,
            "id": usingTransIndex,
            "incoming": incomingSwitch.isOn,
            "location": myLocation,
            "title": titleTextField.text ?? "*EMPTY*",
            "total": Double(totalTextField.text?.replacingOccurrences(of: ",", with: ".") ?? "0")!
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
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        locationButton.isSelected = !locationButton.isSelected
        var newLocation: GeoPoint = GeoPoint(latitude: 0, longitude: 0)
        
        if (locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways) {
            if (locationButton.isSelected == true) {
                newLocation = GeoPoint(latitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.longitude)
            }
            myLocation = newLocation
        }
        locationButton.tintColor = locationButton.isSelected ? .white : .lightText
    }
}
