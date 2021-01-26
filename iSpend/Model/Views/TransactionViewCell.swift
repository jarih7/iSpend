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
        clipsToBounds = true
        layer.masksToBounds = false
        backgroundColor = .tertiarySystemBackground
        layer.cornerRadius = 10
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
        setupLabels()
        setupShadows()
    }
    
    func setupLabels() {
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
    
    func setupShadows() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.1
    }
    
    func shring(down: Bool) {
        UIView.animate(withDuration: 0.12, delay: 0, options: .allowUserInteraction) {
            self.transform = down ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
        } completion: { _ in }
    }
    
    override var isHighlighted: Bool {
        didSet {
            shring(down: isHighlighted)
        }
    }
}
