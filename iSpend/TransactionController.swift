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

class TransactionController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
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
    @IBOutlet weak var locationSymbol: UIButton!
    
    let db = Firestore.firestore()
    var listener: ListenerRegistration? = nil
    var transaction: Transaction? = nil
    
    let locationManager = CLLocationManager()

    var transId: Int = 0
    let currency: String = "CZK"
    let dateFormatter = DateFormatter()
    var hasLocation: Bool = false
    let locationButtonOnSymbolName: String = "trash.circle.fill"
    let locationButtonOffSymbolName: String = "location.circle.fill"
    let locationSet: String = "location"
    let locationNotSet: String = "no location"
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
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
        mapView.delegate = self
        locationManager.delegate = self
        locationLabel.isHidden = true
        locationSymbol.isHidden = true
        
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
            
            transaction = Transaction(counterparty: transactionData["counterparty"] as? String ?? "COUNTERPARTY ERROR", date: Date(timeIntervalSince1970: TimeInterval((transactionData["date"] as! Timestamp).seconds)), id: transactionData["id"] as? Int ?? 999999, incoming: transactionData["incoming"] as? Bool ?? false, latitude: (transactionData["location"] as! GeoPoint).latitude, longitude: (transactionData["location"] as! GeoPoint).longitude, title: transactionData["title"] as? String ?? "TITLE ERROR", total: transactionData["total"] as? Double ?? 123.45)
            
            let location = MKPointAnnotation()
            location.coordinate = CLLocationCoordinate2D(latitude: transaction!.latitude, longitude: transaction!.longitude)
            mapView.addAnnotation(location)
            mapView.setCenter(location.coordinate, animated: true)
            mapView.setRegion(MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
            setupView()
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
        titleLabel.text = transaction?.title
        counterpartyLabel.text = transaction?.counterparty
        dateLabel.text = dateFormatter.string(from: transaction!.date)
        priceLabel.text = String(format: "%.2f", transaction!.total)
        totalLabelTitle.textColor = .lightText
        dateLabelTitle.textColor = .lightText
        counterpartyLabelTitle.textColor = .lightText
        currencyLabel.textColor = .lightText
        
        if (transaction?.incoming == true) {
            symbolLabel.text = "→"
            symbolLabel.textColor = .systemGreen
        } else {
            symbolLabel.text = "←"
            symbolLabel.textColor = .systemOrange
        }
        
        locationLabel.isHidden = (transaction?.latitude == 0 && transaction?.longitude == 0) ? true : false
        locationSymbol.isHidden = (transaction?.latitude == 0 && transaction?.longitude == 0) ? true : false
        mapView.isHidden = (transaction?.latitude == 0 && transaction?.longitude == 0) ? true : false
        
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = 10
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
            db.collection("iSpend").document("UtE3HXvUEmamvjtRaDDs").updateData(["transMap." + transId.description : FieldValue.delete()])
            navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

