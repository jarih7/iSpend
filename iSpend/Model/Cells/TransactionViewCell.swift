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
    
    var incoming: Bool = false
    var id: Int = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
        setupLabels()
        setupShadows()
    }
    
    func setupView() {
        clipsToBounds = true
        layer.masksToBounds = false
        backgroundColor = .tertiarySystemBackground
        layer.cornerRadius = 10
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
    }
    
    func setupLabels() {
        if (incoming == true) {
            totalSymbol.textColor = .systemGreen
        } else {
            totalSymbol.textColor = .systemOrange
        }
        
        total.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .bold)
    }
    
    func setupShadows() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.1
    }
    
    func shring(down: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: .curveEaseInOut) {
            self.transform = down ? CGAffineTransform(scaleX: 0.92, y: 0.92) : .identity
        } completion: { _ in }
    }
    
    override var isHighlighted: Bool {
        didSet {
            shring(down: isHighlighted)
        }
    }
}
