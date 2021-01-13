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
    @IBOutlet weak var incomingSegmentControl: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var dismissButtonBackground: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    var headerText: String = "New Transaction"
    
    let db = Firestore.firestore()
    var listener: ListenerRegistration? = nil
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
            dismissButtonBackground.isHidden = true
        } else {
            dismissButton.isHidden = false
            dismissButtonBackground.isHidden = false
        }
        
        setupFunctionality()
        setupStyle()
        setupContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("STARTED LISTENNING FROM ADD_NEW_TRANSACTION...\n")
        startListening()
        scrollView.setContentOffset(CGPoint.zero, animated: true)
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("STOPPED LISTENNING FROM ADD_NEW_TRANSACTION...\n")
        listener?.remove()
        locationManager.stopUpdatingLocation()
    }
    
    func startListening() {
        listener = db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").addSnapshotListener { [self] (documentSnapshot, error) in
            
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
        dismissButton.tintColor = .systemGray4
        dismissButtonBackground.tintColor = .systemGray
        
        locationButton.setImage(UIImage(systemName: "location.fill"), for: .selected)
        locationButton.setImage(UIImage(systemName: "location.slash.fill"), for: .normal)
        locationButton.tintColor = myLocation == GeoPoint(latitude: 0, longitude: 0) ? .systemGray : .systemBlue
        
        titleTextField.layer.cornerRadius = 5
        counterpartyTextField.layer.cornerRadius = 5
        totalTextField.layer.cornerRadius = 5
        
        titleTextField.attributedPlaceholder = NSAttributedString(string: "enter transaction's title", attributes: [NSAttributedString.Key.foregroundColor : UIColor.secondaryLabel])
        counterpartyTextField.attributedPlaceholder = NSAttributedString(string: "enter counterparty's name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.secondaryLabel])
        totalTextField.attributedPlaceholder = NSAttributedString(string: "enter transaction's total", attributes: [NSAttributedString.Key.foregroundColor : UIColor.secondaryLabel])
        
        totalTextField.keyboardType = UIKeyboardType.numbersAndPunctuation
        //incomingSwitch.isOn = false
        incomingSegmentControl.selectedSegmentIndex = 1
        //incomingSwitch.tintColor = .systemOrange
        //incomingSwitch.layer.cornerRadius = incomingSwitch.frame.height / 2
        //incomingSwitch.backgroundColor = .systemOrange
        
        saveButton.backgroundColor = .systemBlue
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 10
        
        datePicker.backgroundColor = .systemBackground
        datePicker.layer.cornerRadius = 10
        datePicker.layer.masksToBounds = true
    }
    
    func setupContent() {
        headerLabel.text = headerText
        titleTextField.text = passedTitle
        counterpartyTextField.text = passedConterparty
        totalTextField.text = passedTotal
        datePicker.date = passedDate
        //incomingSwitch.isOn = passedIncoming
        incomingSegmentControl.selectedSegmentIndex = passedIncoming ? 0 : 1
    }
    
    func resetFields() {
        titleTextField.text = ""
        counterpartyTextField.text = ""
        totalTextField.text = ""
        datePicker.date = Date()
        //incomingSwitch.isOn = false
        incomingSegmentControl.selectedSegmentIndex = 1
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let usingTransIndex = passedUpdate == false ? newTransactionIndex : passedIndex
        let newTransaction: NSDictionary = [
            "counterparty": counterpartyTextField.text ?? "*EMPTY*",
            "date": datePicker.date,
            "id": usingTransIndex,
            "incoming": incomingSegmentControl.selectedSegmentIndex == 0 ? true : false,
            "location": myLocation,
            "title": titleTextField.text ?? "*EMPTY*",
            "total": Double(totalTextField.text?.replacingOccurrences(of: ",", with: ".") ?? "0")!
        ]
        
        print("writing to firestore")
        db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").updateData(["transMap." + usingTransIndex.description : newTransaction])
        
        if (passedUpdate == false) {
            print("writing to firestore")
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
        locationButton.tintColor = locationButton.isSelected ? .systemBlue : .systemGray
    }
}
