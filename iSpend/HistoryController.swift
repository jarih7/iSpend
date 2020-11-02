//
//  HistoryController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 29/10/2020.
//

import UIKit
import FirebaseDatabase

class HistoryController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var transactionsCollectionView: UICollectionView!
    
    let dbRef = Database.database().reference()
    var transactions: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionsCollectionView.delegate = self
        transactionsCollectionView.dataSource = self
        
        dbRef.child("transactions").observe(.value, with: { [self] (snapshot) in
            transactions = snapshot.value as? NSMutableArray ?? []
            transactions.removeObject(identicalTo: NSNull())
            transactionsCollectionView.reloadData()
        })
    }
    
    func setupCellContent(cell: TransactionViewCell, transaction: NSDictionary) {
        let id = transaction["id"] as! Int
        let title = transaction["title"] as! String
        let total = transaction["total"] as! Double
        let incoming = transaction["incoming"] as! Bool
        let dateString = transaction["date"] as! String
        let counterparty = transaction["counterparty"] as! String
        
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US")
        df.dateStyle = .medium
        let date = df.date(from: dateString)!
        
        cell.label.text = title
        cell.total.text = String(format: "%.2f", total) + " Kč"
        
        if (incoming == true) {
            cell.totalSymbol.text = "→"
        } else {
            cell.totalSymbol.text = "←"
        }
        
        cell.counterparty.text = counterparty
        cell.date.text = dateString
    }
    
    func setupCellStyle(cell: TransactionViewCell, transaction: NSDictionary) {
        cell.backgroundColor = .systemBlue
        cell.layer.cornerRadius = 10
        cell.label.textColor = .white
        cell.total.textColor = .white
        
        let incoming: Bool = transaction["incoming"] as! Bool
        
        if (incoming == true) {
            cell.totalSymbol.textColor = .green
        } else {
            cell.totalSymbol.textColor = .systemOrange
        }
        
        cell.counterparty.textColor = .white
        cell.date.textColor = .white
    }
    
    //----------------------------------------------------
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TransactionViewCell", for: indexPath) as! TransactionViewCell
        
        let transaction = transactions[indexPath.row] as! NSDictionary
        
        setupCellContent(cell: cell, transaction: transaction)
        setupCellStyle(cell: cell, transaction: transaction)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: transactionsCollectionView.frame.width - 40, height: 100.0)
    }
}

