//
//  HistoryController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 29/10/2020.
//

import UIKit
import FirebaseDatabase

class HistoryController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var transactionsCollectionView: UICollectionView!
    
    let dbRef = Database.database().reference()
    var transactions: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionsCollectionView.delegate = self
        transactionsCollectionView.dataSource = self
        
        dbRef.child("transactions").observeSingleEvent(of: .value) { [self] (snapshot) in
            transactions = snapshot.value as? NSArray ?? []
            //for transaction in self.transactions {
            //    print("trans: \(transaction)\n")
            //}
            transactionsCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TransactionViewCell", for: indexPath) as! TransactionViewCell
        
        let transaction = transactions[indexPath.row] as! NSDictionary
        cell.label.text = transaction["title"] as? String
        
        return cell
    }
}
