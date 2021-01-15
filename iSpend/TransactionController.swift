//
//  TransactionController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 03/11/2020.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore

class TransactionController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, BaseProtocol {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var counterpartyLabelTitle: UILabel!
    @IBOutlet weak var counterpartyLabel: UILabel!
    @IBOutlet weak var dateLabelTitle: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var totalLabelTitle: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var dismissButtonBackground: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    
    var db = Firestore.firestore()//
    var listener: ListenerRegistration? = nil//
    var transaction: Transaction? = nil
    var transactions: [Transaction] = []//
    var changedValues: [String:Any] = [:]//
    
    let locationManager = CLLocationManager()
    let dateFormatter = DateFormatter()//
    var dateComponentDays = DateComponents()//
    var dateComponentMonts = DateComponents()//

    var transId: Int = 0
    var LTId: Int = Int()//
    var currency: String = "CZK"//
    var hasLocation: Bool = false
    let locationButtonOnSymbolName: String = "trash.circle.fill"
    let locationButtonOffSymbolName: String = "location.circle.fill"
    let locationSet: String = "location"
    let locationNotSet: String = "no location"
    var isQuickView: Bool = false
    
    var LMI: Double = Double()//
    var LMO: Double = Double()//
    var LWI: Double = Double()//
    var LWO: Double = Double()//
    
    var updatedLMI: Double = Double()//
    var updatedLMO: Double = Double()//
    var updatedLWI: Double = Double()//
    var updatedLWO: Double = Double()//
    
    var LMFromDate: Date = Date()//
    var LMToDate: Date = Date()//
    
    var updatedLMFromDate: Date = Date()//
    var updatedLMToDate: Date = Date()//
    
    override func viewWillAppear(_ animated: Bool) {
        print("STARTED LISTENNING FROM TRANSACTION DETAIL...")
        startListening()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("STOPPED LISTENNING FROM TRANSACTION DETAIL...\n")
        listener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        setupView()
        setupDateFormatter()
    }
    
    func startListening() {
        listener = db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").addSnapshotListener { [self]
            (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            let map = data["transMap"] as! Dictionary<String, Any>
            LTId = data["LTId"] as? Int ?? -1
            
            if let transactionData = map[String(transId)] as? [String : Any] {
                transaction = Transaction(counterparty: transactionData["counterparty"] as? String ?? "COUNTERPARTY ERROR", date: Date(timeIntervalSince1970: TimeInterval((transactionData["date"] as! Timestamp).seconds)), id: transactionData["id"] as? Int ?? 999999, incoming: transactionData["incoming"] as? Bool ?? false, latitude: (transactionData["location"] as! GeoPoint).latitude, longitude: (transactionData["location"] as! GeoPoint).longitude, title: transactionData["title"] as? String ?? "TITLE ERROR", total: transactionData["total"] as? Double ?? 123.45)
            }
            
            let location = MKPointAnnotation()
            location.coordinate = CLLocationCoordinate2D(latitude: transaction!.latitude, longitude: transaction!.longitude)
            mapView.addAnnotation(location)
            mapView.setCenter(location.coordinate, animated: true)
            mapView.setRegion(MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
            
            updateView()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
    
    func setupView() {
        view.backgroundColor = .systemBackground
        backButton.isHidden = isQuickView ? true : false
        backButton.tintColor = .systemBlue
        backButton.setTitleColor(.systemBlue, for: .normal)
        
        dismissButton.isHidden = isQuickView ? false : true
        dismissButton.tintColor = .systemGray5
        dismissButtonBackground.isHidden = isQuickView ? false : true
        dismissButtonBackground.tintColor = .systemGray

        optionsButton.tintColor = .systemBlue
        
        titleLabel.textColor = .label
        counterpartyLabel.textColor = .label
        totalLabelTitle.textColor = .secondaryLabel
        dateLabelTitle.textColor = .secondaryLabel
        counterpartyLabelTitle.textColor = .secondaryLabel
        dateLabel.textColor = .label
        
        priceLabel.textColor = .label
        priceLabel.font = UIFont.monospacedSystemFont(ofSize: 30, weight: .bold)
        
        currencyLabel.text = "(\(currency))"
        currencyLabel.textColor = .secondaryLabel
        
        locationManager.delegate = self
        locationLabel.isHidden = true
        locationLabel.textColor = .secondaryLabel
        
        mapView.delegate = self
        mapView.isHidden = true
        mapView.layer.cornerRadius = 10
    }
    
    func updateView() {
        titleLabel.text = transaction?.title
        counterpartyLabel.text = transaction?.counterparty
        dateLabel.text = dateFormatter.string(from: transaction!.date)
        priceLabel.text = String(format: "%.2f", transaction!.total)
        
        if (transaction?.incoming == true) {
            symbolLabel.text = "→"
            symbolLabel.textColor = .systemGreen
        } else {
            symbolLabel.text = "←"
            symbolLabel.textColor = .systemOrange
        }
        
        locationLabel.isHidden = (transaction?.locationEnabled())! ? false : true
        mapView.isHidden = (transaction?.locationEnabled())! ? false : true
    }
    
    func setupDateFormatter() {
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "d. M. yyyy"
        dateComponentDays.day = -7
        dateComponentMonts.month = -1
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if(gestureRecognizer.isEqual(navigationController?.interactivePopGestureRecognizer)) {
            navigationController?.popViewController(animated: true)
            locationManager.stopUpdatingLocation()
            listener?.remove()
        }
        return false
    }
    
    @IBAction func optionsButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Actions", message: "What do you want to do with this Transaction?", preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { [self] (UIAlertAction) in
            print("EDIT ACTION SELECTED")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let addTC = storyboard.instantiateViewController(identifier: "AddTransactionController") as! AddTransactionController
            
            addTC.headerText = "Edit Transaction"
            addTC.passedIndex = transId
            addTC.passedTitle = transaction!.title
            addTC.passedConterparty = transaction!.counterparty
            addTC.passedTotal = String(format: "%.2f", transaction!.total)
            addTC.passedDate = transaction!.date
            addTC.passedIncoming = transaction!.incoming
            addTC.myLocation = GeoPoint(latitude: transaction!.latitude, longitude: transaction!.longitude)
            addTC.passedUpdate = true
            
            present(addTC, animated: true, completion: nil)
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [self] (UIAlertAction) in
            listener?.remove()
            
            //update LTId
            if (transId == LTId) {
                print("DELETING THE LATEST ONE")
                //that means this Transaction is the latest one -> I have to update the id of the new latest Transaction
                db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        
                        let map = data!["transMap"]! as! Dictionary<String, Any>
                        var procItem: [String:Any] = [:]
                        transactions.removeAll()
                        
                        for item in map {
                            procItem = item.value as! [String : Any]
                            transactions.append(Transaction(counterparty: procItem["counterparty"] as? String ?? "COUNTERPARTY ERROR", date: Date(timeIntervalSince1970: TimeInterval((procItem["date"] as! Timestamp).seconds)), id: procItem["id"] as? Int ?? 999999, incoming: procItem["incoming"] as? Bool ?? false, latitude: (procItem["location"] as! GeoPoint).latitude, longitude: (procItem["location"] as! GeoPoint).longitude, title: procItem["title"] as? String ?? "TITLE ERROR", total: procItem["total"] as? Double ?? 123.45))
                        }
                        
                        if (!transactions.isEmpty) {
                            print("SORTING TRANSACTIONS2")
                            transactions.sort { (tr1, tr2) -> Bool in
                                if (tr1.date.compare(tr2.date) == .orderedDescending) {
                                    return true
                                } else if (tr1.date.compare(tr2.date) == .orderedAscending) {
                                    return false
                                } else {
                                    return tr1.id > tr2.id
                                }
                            }
                            transactions.remove(at: 0)
                        }
                        
                        if let newLastTransaction: Transaction = transactions.first {
                            let newLastTransactionId: Int = newLastTransaction.id
                            if (LTId != newLastTransactionId) {
                                print("writing to firestore7")
                                db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").updateData(
                                    ["LTId" : newLastTransactionId,
                                     "transMap." + transId.description : FieldValue.delete()])
                                
                                updateTotals()
                            }
                        } else {
                            print("NO TRANSACTIONS LEFT 1")
                            if (LTId != -1) {
                                print("writing to firestore8")
                                db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").updateData(["LTId" : -1, "LMI" : 0, "LMO" : 0, "LWI" : 0, "LWO" : 0, "nextTransactionIndex" : 0, "LMFD" : Date(), "LMTD" : Date(), "transMap." + transId.description : FieldValue.delete()])
                            }
                        }
                    } else {
                        print("Document does not exist")
                    }
                }
            } else {
                //transaction being deleted is not the latest one
                print("writing to firestore9")
                db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").updateData(["transMap." + transId.description : FieldValue.delete()])
            }
            
            if (isQuickView == true) {
                dismiss(animated: true, completion: nil)
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

