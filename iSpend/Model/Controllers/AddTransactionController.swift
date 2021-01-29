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
    
    var passedIndex: Int = 0
    var passedTitle: String = ""
    var passedConterparty: String = ""
    var passedTotal: String = ""
    var passedDate: Date = Date()
    var passedIncoming: Bool = false
    var passedUpdate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFunctionality()
        setupStyle()
        setupContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollView.setContentOffset(CGPoint.zero, animated: true)
        locationManager.startUpdatingLocation()
        
        if (passedUpdate == false) {
            incomingSegmentControl.selectedSegmentIndex = DataManagement.sharedInstance.defaultIsIncoming == true ? 0 : 1
        } else {
            incomingSegmentControl.selectedSegmentIndex = passedIncoming == true ? 0 : 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    func setupFunctionality() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        //saveButton.translatesAutoresizingMaskIntoConstraints = false
        //saveButton.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        
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
        locationButton.setImage(UIImage(systemName: "location.fill"), for: .selected)
        locationButton.setImage(UIImage(systemName: "location.slash.fill"), for: .normal)
        locationButton.tintColor = myLocation == GeoPoint(latitude: 0, longitude: 0) ? .systemGray : .systemBlue
        
        titleTextField.attributedPlaceholder = NSAttributedString(string: "enter transaction's title", attributes: [NSAttributedString.Key.foregroundColor : UIColor.secondaryLabel, NSAttributedString.Key.font : UIFont(name: "SFProRounded-Regular", size: 18)!])
        counterpartyTextField.attributedPlaceholder = NSAttributedString(string: "enter counterparty's name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.secondaryLabel, NSAttributedString.Key.font : UIFont(name: "SFProRounded-Regular", size: 18)!])
        totalTextField.attributedPlaceholder = NSAttributedString(string: "enter transaction's total", attributes: [NSAttributedString.Key.foregroundColor : UIColor.secondaryLabel, NSAttributedString.Key.font : UIFont(name: "SFProRounded-Regular", size: 18)!])
        totalTextField.keyboardType = UIKeyboardType.numbersAndPunctuation
        
        saveButton.layer.masksToBounds = true
        saveButton.layer.cornerRadius = 10
        
        incomingSegmentControl.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "SFCompactRounded-Medium", size: 13)!], for: .normal)
        
        datePicker.backgroundColor = .tertiarySystemBackground
        datePicker.layer.masksToBounds = true
        datePicker.layer.cornerRadius = 10
    }
    
    func setupContent() {
        headerLabel.text = headerText
        titleTextField.text = passedTitle
        counterpartyTextField.text = passedConterparty
        totalTextField.text = passedTotal
        datePicker.date = passedDate
    }
    
    func resetFields() {
        titleTextField.text = ""
        counterpartyTextField.text = ""
        totalTextField.text = ""
        datePicker.date = Date()
        locationButton.isSelected = false
        locationButton.tintColor = .systemGray
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
        }
        
        headerLabel.text = "New Transaction"
        resetFields()
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
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
