//
//  LastTransactionView.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 08/12/2020.
//

import UIKit

class LastTransactionView: UIControl {
    @IBOutlet weak var ltTitle: UILabel!
    @IBOutlet weak var ltTotal: UILabel!
    @IBOutlet weak var ltIncomingSymbol: UILabel!
    @IBOutlet weak var ltcounterpartyLabel: UILabel!
    @IBOutlet weak var ltDateLabel: UILabel!
    @IBOutlet weak var ltCounterparty: UILabel!
    @IBOutlet weak var ltDate: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setupView() {
        layer.cornerRadius = 7
        ltcounterpartyLabel.textColor = .lightText
        ltDateLabel.textColor = .lightText
        layer.shadowColor = UIColor(red: 32/255, green: 56/255, blue: 100/255, alpha: 1).cgColor
        layer.shadowOffset = CGSize(width: 2, height: 4)
        layer.shadowRadius = 7
        layer.shadowOpacity = 1
    }
}
