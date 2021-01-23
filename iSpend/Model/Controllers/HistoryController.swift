//
//  HistoryController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 29/10/2020.
//

import UIKit
import FirebaseFirestore

class HistoryController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var transactionsCollectionView: UICollectionView!
    
    let dateFormatter = DateFormatter()
    var dateComponentDays = DateComponents()
    var dateComponentMonts = DateComponents()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        setupCollectionView()
        setupDateFormatter()
        transactionsCollectionView.delaysContentTouches = false
        DataManagement.sharedInstance.updateHistoryData = updateHistoryData
    }
    
    func updateHistoryData() {
        transactionsCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        transactionsCollectionView.contentInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 16.0, right: 16.0)
    }
    
    func setupCollectionView() {
        transactionsCollectionView.automaticallyAdjustsScrollIndicatorInsets = true
        transactionsCollectionView.delegate = self
        transactionsCollectionView.dataSource = self
    }
    
    func setupDateFormatter() {
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "d. M. yyyy"
        dateComponentDays.day = -7
        dateComponentMonts.month = -1
    }
    
    func setupCellContent(cell: TransactionViewCell, transaction: Transaction) {
        cell.id = transaction.id
        cell.label.text = transaction.title
        cell.total.text = Int(transaction.total).description
        
        if (transaction.incoming == true) {
            cell.incoming = true
            cell.totalSymbol.text = "→"
        } else {
            cell.incoming = false
            cell.totalSymbol.text = "←"
        }
        
        if (transaction.locationEnabled()) {
            cell.locationBadge.isHidden = false
        } else {
            cell.locationBadge.isHidden = true
        }
        
        cell.counterparty.text = transaction.counterparty
        cell.date.text = dateFormatter.string(from: transaction.date)
        cell.doubleTotalValue = transaction.total
    }
    
    //----------------------------------------------------
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataManagement.sharedInstance.transactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TransactionViewCell", for: indexPath) as! TransactionViewCell
        
        let transaction = DataManagement.sharedInstance.transactions[indexPath.row] as Transaction
        setupCellContent(cell: cell, transaction: transaction)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: transactionsCollectionView.frame.width - 32, height: 100.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: transactionsCollectionView.frame.width - 32, height: 90.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let historyViewHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? HistoryViewHeader {
            historyViewHeader.headerLabel.text = "History"
            historyViewHeader.headerLabel.textColor = .label
            historyViewHeader.headerLabel.font = UIFont.systemFont(ofSize: 45.0, weight: .heavy)
            return historyViewHeader
        }
        return UICollectionReusableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? TransactionViewCell {
            let vc = segue.destination as! TransactionController
            vc.transId = cell.id
        }
    }
    
    @IBAction func unwindToController(segue: UIStoryboardSegue) {
        
    }
}

