//
//  SettingsViewCell.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 26/01/2021.
//

import UIKit

class SettingsViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBAction func segmentControlTapped(_ sender: UISegmentedControl) {
        DataManagement.sharedInstance.updateDefaultTransactionType(to: segmentControl.selectedSegmentIndex)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .tertiarySystemBackground
    }
}
