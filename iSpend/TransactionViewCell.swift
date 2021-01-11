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
        backgroundColor = .tertiarySystemBackground
        layer.cornerRadius = 10
        
        label.textColor = .label
        total.textColor = .label
        
        if (incoming == true) {
            totalSymbol.textColor = .systemGreen
        } else {
            totalSymbol.textColor = .systemOrange
        }
        
        total.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .bold)
        counterpartyLabel.textColor = .secondaryLabel
        counterparty.textColor = .label
        dateLabel.textColor = .secondaryLabel
        date.textColor = .label
        
        locationBadge.tintColor = .systemBlue
    }
}
