//
//  RatesController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 13/11/2020.
//

import UIKit

class RatesController: UIViewController {
    @IBOutlet weak var eurView: ERView!
    @IBOutlet weak var usdView: ERView!
    @IBOutlet weak var gbpView: ERView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        eurView.setupView(currencyCode: "EUR")
        usdView.setupView(currencyCode: "USD")
        gbpView.setupView(currencyCode: "GBP")
    }
}
