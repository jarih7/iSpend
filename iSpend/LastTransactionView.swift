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
    @IBOutlet weak var locationBadge: UIButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setupView() {
        backgroundColor = .tertiarySystemBackground
        layer.cornerRadius = 10
        
        ltTitle.textColor = .label
        ltTotal.textColor = .label
        ltCounterparty.textColor = .label
        ltDate.textColor = .label
        ltcounterpartyLabel.textColor = .secondaryLabel
        ltDateLabel.textColor = .secondaryLabel
    }
}
