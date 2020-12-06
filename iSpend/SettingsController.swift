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
    let versionNumber: String = "0.7"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appNameLabel.text = appName
        appNameLabel.textColor = .lightText
        versionLabel.textColor = .lightText
        versionNumberLabel.text = versionNumber
        versionNumberLabel.textColor = .lightText
        copyrightLabel.textColor = .lightText
    }
}
