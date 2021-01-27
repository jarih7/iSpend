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
    @IBOutlet weak var counterpartyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var dismissButtonBackground: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    
    var location = MKPointAnnotation()
    let locationManager = CLLocationManager()
    var transId: Int = 0
    var isQuickView: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        DataManagement.sharedInstance.getTransactionById(id: transId)
        DataManagement.sharedInstance.updateTransactionDetailData = updateTransactionDetailData
        updateTransactionDetailData(firstLoad: true)
    }
    
    func updateTransactionDetailData(firstLoad: Bool = false) {
        DispatchQueue.main.async { [self] in
            if (firstLoad == false) {
                DataManagement.sharedInstance.getTransactionById(id: transId)
            }
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
        backButton.isHidden = isQuickView ? true : false
        dismissButton.isHidden = isQuickView ? false : true
        dismissButtonBackground.isHidden = isQuickView ? false : true
        priceLabel.font = UIFont.monospacedSystemFont(ofSize: 30, weight: .bold)
        currencyLabel.text = "(\(DataManagement.sharedInstance.currency))"
        locationManager.delegate = self
        locationLabel.isHidden = true
        mapView.delegate = self
        mapView.isHidden = true
        mapView.layer.cornerRadius = 10
    }
    
    func updateView() {
        titleLabel.text = DataManagement.sharedInstance.presentedTransaction?.title ?? "EMPTY"
        counterpartyLabel.text = DataManagement.sharedInstance.presentedTransaction?.counterparty ?? "EMPTY"
        dateLabel.text = DataManagement.sharedInstance.dateFormatter.string(from: DataManagement.sharedInstance.presentedTransaction?.date ?? Date())
        priceLabel.text = String(format: "%.2f", DataManagement.sharedInstance.presentedTransaction?.total ?? 0.0)
        
        if (DataManagement.sharedInstance.presentedTransaction?.incoming == true) {
            symbolLabel.text = "→"
            symbolLabel.textColor = .systemGreen
        } else {
            symbolLabel.text = "←"
            symbolLabel.textColor = .systemOrange
        }
        
        locationLabel.isHidden = (DataManagement.sharedInstance.presentedTransaction?.locationEnabled())! ? false : true
        mapView.isHidden = (DataManagement.sharedInstance.presentedTransaction?.locationEnabled())! ? false : true
        
        location.coordinate = CLLocationCoordinate2D(latitude: DataManagement.sharedInstance.presentedTransaction?.latitude ?? 0.0, longitude: DataManagement.sharedInstance.presentedTransaction?.longitude ?? 0.0)
        mapView.addAnnotation(location)
        mapView.setCenter(location.coordinate, animated: true)
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if (gestureRecognizer.isEqual(navigationController?.interactivePopGestureRecognizer)) {
            navigationController?.popViewController(animated: true)
            locationManager.stopUpdatingLocation()
        }
        return false
    }
    
    @IBAction func optionsButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Transaction Options", message: "What do you want to do with this Transaction?", preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { [self] (UIAlertAction) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let addTC = storyboard.instantiateViewController(identifier: "AddTransactionController") as! AddTransactionController
            
            addTC.headerText = "Edit Transaction"
            addTC.passedIndex = transId
            addTC.passedTitle = DataManagement.sharedInstance.presentedTransaction?.title ?? "EMPTY"
            addTC.passedConterparty = DataManagement.sharedInstance.presentedTransaction?.counterparty ?? "EMPTY"
            addTC.passedTotal = String(format: "%.2f", DataManagement.sharedInstance.presentedTransaction?.total ?? 0.0)
            addTC.passedDate = DataManagement.sharedInstance.presentedTransaction?.date ?? Date()
            addTC.passedIncoming = DataManagement.sharedInstance.presentedTransaction?.incoming ?? false
            addTC.myLocation = GeoPoint(latitude: DataManagement.sharedInstance.presentedTransaction?.latitude ?? 0.0, longitude: DataManagement.sharedInstance.presentedTransaction?.longitude ?? 0.0)
            addTC.passedUpdate = true
            present(addTC, animated: true, completion: nil)
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [self] (UIAlertAction) in
            DataManagement.sharedInstance.deleteTransactionById(id: transId)
            
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

