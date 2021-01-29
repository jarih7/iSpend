//
//  WeekView.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 13/11/2020.
//

import UIKit

class WeekView: UIControl {
    @IBOutlet weak var weekInSymbol: UILabel!
    @IBOutlet weak var weekInSum: UILabel!
    @IBOutlet weak var weekOutSymbol: UILabel!
    @IBOutlet weak var weekOutSum: UILabel!
    @IBOutlet weak var weekBalance: UILabel!
    @IBOutlet weak var weekCurrency: UILabel!
    @IBOutlet weak var weekInCurrency: UILabel!
    @IBOutlet weak var weekOutCurrency: UILabel!
    
    func setupView() {
        layer.cornerRadius = 10
        setupLabels()
        setupShadows()
    }
    
    func setupLabels() {
        weekCurrency.text = DataManagement.sharedInstance.currency
        weekInCurrency.text = DataManagement.sharedInstance.currency
        weekOutCurrency.text = DataManagement.sharedInstance.currency
        weekInSum.font = UIFont.monospacedSystemFont(ofSize: 17, weight: .semibold)
        weekOutSum.font = UIFont.monospacedSystemFont(ofSize: 17, weight: .semibold)
        weekBalance.font = UIFont.monospacedSystemFont(ofSize: 30, weight: .bold)
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
