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
    
    func setupViewStyle() {
        layer.cornerRadius = 10
        layer.shadowColor = UIColor(red: 32/255, green: 56/255, blue: 100/255, alpha: 1).cgColor
        layer.shadowOffset = CGSize(width: 2, height: 4)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.9
    }
}
