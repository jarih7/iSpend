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
    @IBOutlet weak var counterpartyLabel: UILabel!
    @IBOutlet weak var counterparty: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var locationBadge: UIButton!
    
    var doubleTotalValue: Double = 0.0
    var incoming: Bool = false
    var id: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        backgroundColor = UIColor(red: 70/255, green: 116/255, blue: 194/255, alpha: 1)
        layer.cornerRadius = 10
        
        label.textColor = .white
        total.textColor = .white
        
        if (incoming == true) {
            totalSymbol.textColor = .green
        } else {
            totalSymbol.textColor = .systemOrange
        }
        
        total.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .bold)
        counterpartyLabel.textColor = .lightText
        counterparty.textColor = .white
        dateLabel.textColor = .lightText
        date.textColor = .white
    }
}
