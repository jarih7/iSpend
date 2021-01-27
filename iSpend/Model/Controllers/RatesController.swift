//
//  RatesController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 13/11/2020.
//

import UIKit

class RatesController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var currencyCollectionView: UICollectionView!
    
    let dateFormatter: DateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
        setupShadows()
        setupDateFormatter()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataManagement.sharedInstance.getERData()
        currencyCollectionView.reloadData()
        lastUpdatedLabel.text = dateFormatter.string(from: Date())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        currencyCollectionView.contentInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
    }
    
    func setupDateFormatter() {
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = .current
    }
    
    func setupCollectionView() {
        currencyCollectionView.automaticallyAdjustsScrollIndicatorInsets = true
        currencyCollectionView.delegate = self
        currencyCollectionView.dataSource = self
    }
    
    func setupCellContent(cell: ERViewCell, index: Int, currency: Currency) {
        cell.baseCurrency.text = DataManagement.sharedInstance.currency
        cell.currencyLabel.text = currency.title
        cell.currencySign.setImage(UIImage(systemName: currency.buttonImage)?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 22.0, weight: .semibold, scale: .large)), for: .normal)
        cell.currencyValue.text = String(format: "%.4f", DataManagement.sharedInstance.currencies[index].value)
        cell.currencyValue.font = UIFont.monospacedSystemFont(ofSize: 25, weight: .bold)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataManagement.sharedInstance.currencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ERViewCell", for: indexPath) as! ERViewCell
        let currencyData = DataManagement.sharedInstance.currencies[indexPath.row] as Currency
        setupCellContent(cell: cell, index: indexPath.row, currency: currencyData)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: currencyCollectionView.frame.width - 32, height: 50.0)
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        DataManagement.sharedInstance.getERData()
        currencyCollectionView.reloadData()
        lastUpdatedLabel.text = dateFormatter.string(from: Date())
    }
    
    func setupLabels() {
        lastUpdatedLabel.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
    }
    
    func setupShadows() {
        updateButton.layer.shadowColor = UIColor.black.cgColor
        updateButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        updateButton.layer.shadowRadius = 5
        updateButton.layer.shadowOpacity = 0.1
    }
}
