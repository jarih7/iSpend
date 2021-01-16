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
    
    let db = Firestore.firestore()
    var listener: ListenerRegistration? = nil
    var map: [String:Any] = [:]
    var newerMap: [String:Any] = [:]
    var procItem: [String:Any] = [:]
    var updatedData: [String:Any] = [:]
    var transactions: [Transaction] = []
    var usingTransIndex: Int = Int()
    let locationManager = CLLocationManager()
    var myLocation: GeoPoint = GeoPoint(latitude: 0, longitude: 0)
    
    let transactionsPath: String = "transMap"
    let newTransactionIndexPath: String = "nextTransIndex"
    var newTransactionIndex = Int()
    var newTransactionPath: String = ""
    
    let dateFormatter = DateFormatter()
    var dateComponentDays = DateComponents()
    var dateComponentMonts = DateComponents()
    var LMFromDate: Date = Date()
    var LMToDate: Date = Date()
    
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
        //setNeedsStatusBarAppearanceUpdate()
        
        setupDateFormatter()
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
            newerMap = data["transMap"] as! Dictionary<String, Any>
            
            //check for any updates
            if (!((map as NSDictionary).isEqual(to: newerMap))) {
                print("⛔️ MAPS NOT EQUAL")
                map = newerMap
                print("✴️ LOCAL MAP UPDATED")
                fillMapWithUpdatedTransactions()
            }
            
            print("✅ MAPS ARE EQUAL")
        }
    }
    
    func fillMapWithUpdatedTransactions() {
        transactions.removeAll()
        procItem = [:]
        
        for item in newerMap {
            procItem = item.value as! [String:Any]
            transactions.append(Transaction(counterparty: procItem["counterparty"] as? String ?? "COUNTERPARTY ERROR", date: Date(timeIntervalSince1970: TimeInterval((procItem["date"] as! Timestamp).seconds)), id: procItem["id"] as? Int ?? 999999, incoming: procItem["incoming"] as? Bool ?? false, latitude: (procItem["location"] as! GeoPoint).latitude, longitude: (procItem["location"] as! GeoPoint).longitude, title: procItem["title"] as? String ?? "TITLE ERROR", total: procItem["total"] as? Double ?? 123.45))
        }
    }
    
    func setupDateFormatter() {
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "d. MM. yyyy"
        dateComponentDays.day = -7
        dateComponentMonts.month = -1
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
        incomingSegmentControl.selectedSegmentIndex = 1
        
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
        incomingSegmentControl.selectedSegmentIndex = passedIncoming ? 0 : 1
    }
    
    func resetFields() {
        titleTextField.text = ""
        counterpartyTextField.text = ""
        totalTextField.text = ""
        datePicker.date = Date()
        locationButton.isSelected = false
        locationButton.tintColor = .systemGray
        incomingSegmentControl.selectedSegmentIndex = 1
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        usingTransIndex = passedUpdate == false ? newTransactionIndex : passedIndex
        let newTransaction: NSDictionary = [
            "counterparty": counterpartyTextField.text ?? "*EMPTY*",
            "date": datePicker.date,
            "id": usingTransIndex,
            "incoming": incomingSegmentControl.selectedSegmentIndex == 0 ? true : false,
            "location": myLocation,
            "title": titleTextField.text ?? "*EMPTY*",
            "total": Double(totalTextField.text?.replacingOccurrences(of: ",", with: ".") ?? "0")!
        ]
        
        if (passedUpdate == true) {
            transactions.removeAll(where: { $0.id == usingTransIndex })
        }
        
        transactions.append(Transaction(counterparty: counterpartyTextField.text ?? "*EMPTY*", date: datePicker.date, id: usingTransIndex, incoming: incomingSegmentControl.selectedSegmentIndex == 0 ? true : false, latitude: myLocation.latitude, longitude: myLocation.longitude, title: titleTextField.text ?? "*EMPTY*", total: Double(totalTextField.text?.replacingOccurrences(of: ",", with: ".") ?? "0")!))
        
        //prepare updatedDataToUpload
        updatedData = [:]
        updatedData["transMap." + usingTransIndex.description] = newTransaction
        
        //creating new transaction
        if (passedUpdate == false) {
            updatedData["nextTransactionIndex"] = newTransactionIndex + 1
        }
        
        //prepare other "info/meta" data for upload
        updateDataAndUpload()
        
        if (passedUpdate == false) {
            tabBarController?.selectedIndex = 1
        } else {
            passedUpdate = false
            dismiss(animated: true, completion: nil)
        }
        
        headerLabel.text = "New Transaction"
        resetFields()
    }
    
    func updateDataAndUpload() {
        var updatedLMI: Double = 0.0
        var updatedLMO: Double = 0.0
        var updatedLWI: Double = 0.0
        var updatedLWO: Double = 0.0
        var updatedLMFromDate: Date = Date()
        var updatedLMToDate: Date = Date()
        
        for item in transactions {
            if (item.date > Calendar.current.date(byAdding: dateComponentDays, to: Date())!) {
                if (item.incoming == true) {
                    updatedLWI += item.total
                    updatedLMI += item.total
                } else {
                    updatedLWO += item.total
                    updatedLMO += item.total
                }
            } else if (item.date > Calendar.current.date(byAdding: dateComponentMonts, to: Date())!) {
                if (item.incoming == true) {
                    updatedLMI += item.total
                } else {
                    updatedLMO += item.total
                }
                
                //get "from" and "to" dates
                if (item.date.compare(LMFromDate) == .orderedAscending) {
                    updatedLMFromDate = item.date
                }
                
                if (item.date.compare(LMToDate) == .orderedDescending) {
                    updatedLMToDate = item.date
                }
            }
        }
        
        updatedData["LMI"] = updatedLMI
        updatedData["LMO"] = updatedLMO
        updatedData["LWI"] = updatedLWI
        updatedData["LWO"] = updatedLWO
        updatedData["LTId"] = usingTransIndex
        updatedData["LMFD"] = updatedLMFromDate
        updatedData["LMTD"] = updatedLMToDate
        
        print("writing to firestore5 and 6")
        db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").updateData(updatedData)
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
