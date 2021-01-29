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
