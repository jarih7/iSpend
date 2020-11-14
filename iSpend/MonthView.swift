//
//  MonthView.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 13/11/2020.
//

import UIKit

class MonthView: UIView {
    @IBOutlet weak var lastMonthLabel: UILabel!
    @IBOutlet weak var monthInSymbol: UILabel!
    @IBOutlet weak var monthInSum: UILabel!
    @IBOutlet weak var monthOutSymbol: UILabel!
    @IBOutlet weak var monthOutSum: UILabel!
    @IBOutlet weak var monthBalanceLabel: UILabel!
    @IBOutlet weak var monthBalance: UILabel!
    @IBOutlet weak var monthCurrency: UILabel!
    @IBOutlet weak var monthInCurrency: UILabel!
    @IBOutlet weak var monthOutCurrency: UILabel!
    
    var currency: String = "CZK"
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setupView() {
        layer.cornerRadius = 10
        lastMonthLabel.text = "Last Month"
        lastMonthLabel.textColor = .white
        monthInSymbol.text = "→"
        monthOutSymbol.text = "←"
        monthInSymbol.textColor = .green
        monthOutSymbol.textColor = .systemOrange
        monthInSum.textColor = .white
        monthOutSum.textColor = .white
        monthBalance.textColor = .white
        monthBalanceLabel.textColor = .white
        monthCurrency.textColor = .white
        monthInCurrency.textColor = .white
        monthOutCurrency.textColor = .white
        monthCurrency.text = currency
        monthInCurrency.text = currency
        monthOutCurrency.text = currency
        monthInSum.font = UIFont.monospacedSystemFont(ofSize: 17, weight: .semibold)
        monthOutSum.font = UIFont.monospacedSystemFont(ofSize: 17, weight: .semibold)
        monthBalance.font = UIFont.monospacedSystemFont(ofSize: 30, weight: .bold)
        layer.shadowColor = UIColor(red: 32/255, green: 56/255, blue: 100/255, alpha: 1).cgColor
        layer.shadowOffset = CGSize(width: 3, height: 5)
        layer.shadowRadius = 8
        layer.shadowOpacity = 1
    }
}
