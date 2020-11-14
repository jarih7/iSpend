//
//  ERView.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 13/11/2020.
//

import UIKit

class ERView: UIView {
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setupView(currencyCode: String) {
        layer.cornerRadius = 10
        layer.shadowColor = UIColor(red: 32/255, green: 56/255, blue: 100/255, alpha: 1).cgColor
        layer.shadowOffset = CGSize(width: 3, height: 5)
        layer.shadowRadius = 8
        layer.shadowOpacity = 1
    }
}
