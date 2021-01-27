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
    @IBOutlet weak var ltCounterparty: UILabel!
    @IBOutlet weak var ltDate: UILabel!
    @IBOutlet weak var locationBadge: UIButton!
    
    func setupView() {
        layer.cornerRadius = 10
        ltTotal.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .bold)
        setupShadows()
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
