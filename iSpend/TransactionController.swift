//
//  TransactionController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 03/11/2020.
//

import UIKit
import MapKit
import FirebaseFirestore

class TransactionController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var counterpartyLabelTitle: UILabel!
    @IBOutlet weak var counterpartyLabel: UILabel!
    @IBOutlet weak var dateLabelTitle: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var totalLabelTitle: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var locationLabelTitle: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    let db = Firestore.firestore()
    var listener: ListenerRegistration? = nil
    var transaction: Transaction? = nil
    
    let locationManager = CLLocationManager()
    var location: CLLocation? = nil

    var transId: Int = 0
    let currency: String = "CZK"
    let dateFormatter = DateFormatter()
    var hasLocation: Bool = false
    let locationButtonOnSymbolName: String = "trash.circle.fill"
    let locationButtonOffSymbolName: String = "location.circle.fill"
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if(gestureRecognizer.isEqual(navigationController?.interactivePopGestureRecognizer)) {
            navigationController?.popViewController(animated: true)
            listener?.remove()
        }
        
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "d. MM. yyyy"
        priceLabel.font = UIFont.monospacedSystemFont(ofSize: 30, weight: .bold)
        currencyLabel.text = "(\(currency))"
        mapView.isHidden = true
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        
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
            let transactionData = map[String(transId)]! as! [String : Any]
            
            transaction = Transaction(counterparty: transactionData["counterparty"] as? String ?? "COUNTERPARTY ERROR", date: Date(timeIntervalSince1970: TimeInterval((transactionData["date"] as! Timestamp).seconds)), id: transactionData["id"] as? Int ?? 999999, incoming: transactionData["incoming"] as? Bool ?? false, title: transactionData["title"] as? String ?? "TITLE ERROR", total: transactionData["total"] as? Double ?? 123.45)
            
            setupView()
        }
    }
    
    func setupView() {
        titleLabel.text = transaction?.title
        counterpartyLabel.text = transaction?.counterparty
        dateLabel.text = dateFormatter.string(from: transaction!.date)
        priceLabel.text = String(format: "%.2f", transaction!.total)
        totalLabelTitle.textColor = .lightText
        dateLabelTitle.textColor = .lightText
        counterpartyLabelTitle.textColor = .lightText
        currencyLabel.textColor = .lightText
        locationLabelTitle.textColor = .lightText
        
        if (transaction?.incoming == true) {
            symbolLabel.text = "→"
            symbolLabel.textColor = .systemGreen
        } else {
            symbolLabel.text = "←"
            symbolLabel.textColor = .systemOrange
        }
        
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = 10
        
        locationButton.setImage(UIImage(systemName: "location.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 21.0, weight: .bold, scale: .large)), for: .normal)
        
        locationButton.setImage(UIImage(systemName: "trash.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 21.0, weight: .bold, scale: .large)), for: .selected)
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
            addTC.passedUpdate = true
            
            present(addTC, animated: true, completion: nil)
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [self] (UIAlertAction) in
            db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").updateData(["transMap." + transId.description : FieldValue.delete()])
            navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: true)
        }
        
        UIView.transition(with: mapView, duration: 0.1, options: .transitionCrossDissolve, animations: { [self] in
            mapView.isHidden = !mapView.isHidden
        }, completion: nil)
        locationButton.isSelected = !locationButton.isSelected
    }
    
}
