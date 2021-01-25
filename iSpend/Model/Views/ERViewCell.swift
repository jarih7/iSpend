//
//  ERViewCell.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 25/01/2021.
//

import UIKit

class ERViewCell: UICollectionViewCell {
    @IBOutlet weak var currencySign: UIButton!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyValue: UILabel!
    @IBOutlet weak var baseCurrency: UILabel!
    
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
        setupShadows()
    }
    
    func setupShadows() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.1
    }
}
