//
//  MonthView.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 13/11/2020.
//

import UIKit

class MonthView: UIControl {
    @IBOutlet weak var fromDate: UILabel!
    @IBOutlet weak var toDate: UILabel!
    @IBOutlet weak var monthInSymbol: UILabel!
    @IBOutlet weak var monthInSum: UILabel!
    @IBOutlet weak var monthOutSymbol: UILabel!
    @IBOutlet weak var monthOutSum: UILabel!
    @IBOutlet weak var monthBalance: UILabel!
    @IBOutlet weak var monthCurrency: UILabel!
    @IBOutlet weak var monthInCurrency: UILabel!
    @IBOutlet weak var monthOutCurrency: UILabel!
    @IBOutlet weak var date1: UILabel!
    @IBOutlet weak var date2: UILabel!
    
    func setupView() {
        layer.cornerRadius = 10
        setupLabels()
        setupShadows()
    }
    
    func setupLabels() {
        monthCurrency.text = DataManagement.sharedInstance.currency
        monthInCurrency.text = DataManagement.sharedInstance.currency
        monthOutCurrency.text = DataManagement.sharedInstance.currency
        monthInSum.font = UIFont.monospacedSystemFont(ofSize: 17, weight: .semibold)
        monthOutSum.font = UIFont.monospacedSystemFont(ofSize: 17, weight: .semibold)
        monthBalance.font = UIFont.monospacedSystemFont(ofSize: 30, weight: .bold)
    }
    
    func setupShadows() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: -2, height: 6)
        layer.shadowRadius = 7
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
