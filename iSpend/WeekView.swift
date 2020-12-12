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
        layer.cornerRadius = 7
        lastWeekLabel.text = "Last Week"
        lastWeekLabel.textColor = .white
        weekInSymbol.text = "→"
        weekOutSymbol.text = "←"
        weekInSymbol.textColor = .green
        weekOutSymbol.textColor = .systemOrange
        weekInSum.textColor = .white
        weekOutSum.textColor = .white
        weekBalance.textColor = .white
        weekBalanceLabel.textColor = .lightText
        weekCurrency.textColor = .white
        weekInCurrency.textColor = .white
        weekOutCurrency.textColor = .white
        weekCurrency.text = currency
        weekInCurrency.text = currency
        weekOutCurrency.text = currency
        weekInSum.font = UIFont.monospacedSystemFont(ofSize: 17, weight: .semibold)
        weekOutSum.font = UIFont.monospacedSystemFont(ofSize: 17, weight: .semibold)
        weekBalance.font = UIFont.monospacedSystemFont(ofSize: 30, weight: .bold)
        layer.shadowColor = UIColor(red: 32/255, green: 56/255, blue: 100/255, alpha: 1).cgColor
        layer.shadowOffset = CGSize(width: 2, height: 4)
        layer.shadowRadius = 7
        layer.shadowOpacity = 0.9
    }
}
