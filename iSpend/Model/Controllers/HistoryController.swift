//
//  HistoryController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 29/10/2020.
//

enum viewType {
    case full
    case month
    case week
}

import UIKit
import FirebaseFirestore

class HistoryController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var transactionsCollectionView: UICollectionView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var dismissButtonBackground: UIButton!
    
    var display = viewType.full
    let dateFormatter = DateFormatter()
    var dateComponentDays = DateComponents()
    var dateComponentMonts = DateComponents()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        
        dismissButtonBackground.layer.shadowColor = UIColor.black.cgColor
        dismissButtonBackground.layer.shadowOffset = CGSize(width: 0, height: 1)
        dismissButtonBackground.layer.shadowRadius = 5
        dismissButtonBackground.layer.shadowOpacity = 0.1
        
        if (display == viewType.week || display == viewType.month) {
            dismissButton.isHidden = false
            dismissButtonBackground.isHidden = false
        } else {
            dismissButton.isHidden = true
            dismissButtonBackground.isHidden = true
        }
        
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
        if (display == viewType.month) {
            return DataManagement.sharedInstance.lastMonthTransactions.count
        } else if (display == viewType.week) {
            return DataManagement.sharedInstance.lastWeekTransactions.count
        } else {
            return DataManagement.sharedInstance.transactions.count
        }
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
        if (display == viewType.month || display == viewType.week) {
            return CGSize(width: transactionsCollectionView.frame.width - 32, height: 70.0)
        } else {
            return CGSize(width: transactionsCollectionView.frame.width - 32, height: 90.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let historyViewHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? HistoryViewHeader {
            
            if (display == viewType.month) {
                historyViewHeader.headerLabel.text = "Last Month"
                historyViewHeader.headerLabel.font = UIFont.systemFont(ofSize: 30.0, weight: .bold)
            } else if (display == viewType.week) {
                historyViewHeader.headerLabel.text = "Last Week"
                historyViewHeader.headerLabel.font = UIFont.systemFont(ofSize: 30.0, weight: .bold)
            } else {
                historyViewHeader.headerLabel.text = "History"
                historyViewHeader.headerLabel.font = UIFont.systemFont(ofSize: 45.0, weight: .heavy)
            }
            
            historyViewHeader.headerLabel.textColor = .label
            return historyViewHeader
        }
        return UICollectionReusableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? TransactionViewCell {
            let vc = segue.destination as! TransactionController
            vc.transId = cell.id
            
            if (display == viewType.month || display == viewType.week) {
                vc.isQuickView = true
            }
        }
    }
    
    @IBAction func unwindToController(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

