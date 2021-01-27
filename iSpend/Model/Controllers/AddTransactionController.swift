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
    @IBOutlet weak var incomingSegmentControl: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var dismissButtonBackground: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    var headerText: String = "New Transaction"
    
    var usingTransIndex: Int = Int()
    let locationManager = CLLocationManager()
    var myLocation: GeoPoint = GeoPoint(latitude: 0, longitude: 0)
    let dateFormatter = DateFormatter()
    var newTransactionPath: String = ""
    
    var passedIndex: Int = 0
    var passedTitle: String = ""
    var passedConterparty: String = ""
    var passedTotal: String = ""
    var passedDate: Date = Date()
    var passedIncoming: Bool = false
    var passedUpdate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        setupDateFormatter()
        setupFunctionality()
        setupStyle()
        setupContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scrollView.setContentOffset(CGPoint.zero, animated: true)
        locationManager.startUpdatingLocation()
        
        if (passedUpdate == false) {
            incomingSegmentControl.selectedSegmentIndex = DataManagement.sharedInstance.defaultIsIncoming == true ? 0 : 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    func setupDateFormatter() {
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "d. MM. yyyy"
    }
    
    func setupFunctionality() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        
        if (passedUpdate == false) {
            dismissButton.isHidden = true
            dismissButtonBackground.isHidden = true
        } else {
            dismissButton.isHidden = false
            dismissButtonBackground.isHidden = false
        }
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
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
        //incomingSegmentControl.selectedSegmentIndex = 1
        
        saveButton.layer.masksToBounds = false
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
        //incomingSegmentControl.selectedSegmentIndex = passedIncoming ? 0 : 1
    }
    
    func resetFields() {
        titleTextField.text = ""
        counterpartyTextField.text = ""
        totalTextField.text = ""
        datePicker.date = Date()
        locationButton.isSelected = false
        locationButton.tintColor = .systemGray
        //incomingSegmentControl.selectedSegmentIndex = 1
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        usingTransIndex = passedUpdate == false ? DataManagement.sharedInstance.nextTransactionIndex : passedIndex
        
        let newTransaction: NSDictionary = [
            "counterparty": counterpartyTextField.text ?? "*EMPTY*",
            "date": datePicker.date,
            "id": usingTransIndex,
            "incoming": incomingSegmentControl.selectedSegmentIndex == 0 ? true : false,
            "location": myLocation,
            "title": titleTextField.text ?? "*EMPTY*",
            "total": Double(totalTextField.text?.replacingOccurrences(of: ",", with: ".") ?? "0")!
        ]
        
        DataManagement.sharedInstance.addOrUpdateTransaction(transaction: newTransaction, updating: passedUpdate, nextIndex: DataManagement.sharedInstance.nextTransactionIndex + 1)
        
        if (passedUpdate == false) {
            tabBarController?.selectedIndex = 1
        } else {
            passedUpdate = false
            dismiss(animated: true, completion: nil)
            //print("UPDATING DETAIL DATA")
            //DataManagement.sharedInstance.updateTransactionDetailData?()
            //print("UPDATE DETAIL DATA CALL FINISHED")
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
