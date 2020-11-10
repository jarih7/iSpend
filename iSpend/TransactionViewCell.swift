//
//  TransactionViewCell.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 01/11/2020.
//

import UIKit

class TransactionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var totalSymbol: UILabel!
    @IBOutlet weak var counterparty: UILabel!
    @IBOutlet weak var date: UILabel!
    
    var doubleTotalValue: Double = 0.0
    var incoming: Bool = false
    var id: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
