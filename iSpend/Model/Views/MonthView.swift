//
//  MonthView.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 13/11/2020.
//

import UIKit

class MonthView: UIControl {
    @IBOutlet weak var lastMonthLabel: UILabel!
    @IBOutlet weak var chevron: UIButton!
    @IBOutlet weak var fromDate: UILabel!
    @IBOutlet weak var toDate: UILabel!
    @IBOutlet weak var monthInSymbol: UILabel!
    @IBOutlet weak var monthInSum: UILabel!
    @IBOutlet weak var monthOutSymbol: UILabel!
    @IBOutlet weak var monthOutSum: UILabel!
    @IBOutlet weak var monthBalanceLabel: UILabel!
    @IBOutlet weak var monthBalance: UILabel!
    @IBOutlet weak var monthCurrency: UILabel!
    @IBOutlet weak var monthInCurrency: UILabel!
    @IBOutlet weak var monthOutCurrency: UILabel!
    @IBOutlet weak var date1: UILabel!
    @IBOutlet weak var date2: UILabel!
    
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
        lastMonthLabel.text = "Last Month"
        monthInSymbol.text = "→"
        monthOutSymbol.text = "←"
        monthInSymbol.textColor = .systemGreen
        monthOutSymbol.textColor = .systemOrange
        monthBalanceLabel.textColor = .secondaryLabel
        monthCurrency.text = currency
        monthInCurrency.text = currency
        monthOutCurrency.text = currency
        monthInSum.font = UIFont.monospacedSystemFont(ofSize: 17, weight: .semibold)
        monthOutSum.font = UIFont.monospacedSystemFont(ofSize: 17, weight: .semibold)
        monthBalance.font = UIFont.monospacedSystemFont(ofSize: 30, weight: .bold)
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
