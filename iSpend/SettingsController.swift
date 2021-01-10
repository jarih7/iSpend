//
//  SettingsController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 13/11/2020.
//

import UIKit

class SettingsController: UIViewController {
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    
    let appName: String = "iSpend™"
    let versionNumber: String = "0.9"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appNameLabel.text = appName
        appNameLabel.textColor = .lightText
        versionLabel.textColor = .lightText
        versionNumberLabel.text = versionNumber
        versionNumberLabel.textColor = .lightText
        copyrightLabel.textColor = .lightText
        
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors =
            [UIColor.init(red: 32/255, green: 56/255, blue: 100/255, alpha: 1).cgColor,
             UIColor.init(red: 49/255, green: 87/255, blue: 149/255, alpha: 1).cgColor]
        view.layer.insertSublayer(gradient, at: 0)
    }
}
