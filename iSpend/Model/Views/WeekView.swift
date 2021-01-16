//
//  WeekView.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 13/11/2020.
//

import UIKit

class WeekView: UIView {
    @IBOutlet weak var lastWeekLabel: UILabel!
    @IBOutlet weak var weekInSymbol: UILabel!
    @IBOutlet weak var weekInSum: UILabel!
    @IBOutlet weak var weekOutSymbol: UILabel!
    @IBOutlet weak var weekOutSum: UILabel!
    @IBOutlet weak var weekBalanceLabel: UILabel!
    @IBOutlet weak var weekBalance: UILabel!
    @IBOutlet weak var weekCurrency: UILabel!
    @IBOutlet weak var weekInCurrency: UILabel!
    @IBOutlet weak var weekOutCurrency: UILabel!
    
    var currency: String = "CZK"
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setupView() {
        backgroundColor = .tertiarySystemBackground
        layer.cornerRadius = 10
        setupLabels()
        setupShadows()
    }
    
    func setupLabels() {
        lastWeekLabel.text = "Last Week"
        weekInSymbol.text = "→"
        weekOutSymbol.text = "←"
        weekInSymbol.textColor = .systemGreen
        weekOutSymbol.textColor = .systemOrange
        weekBalanceLabel.textColor = .secondaryLabel
        weekCurrency.text = currency
        weekInCurrency.text = currency
        weekOutCurrency.text = currency
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
}
