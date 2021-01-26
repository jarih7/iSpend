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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func segmentControlTapped(_ sender: UISegmentedControl) {
        DataManagement.sharedInstance.updateDefaultTransactionType(to: segmentControl.selectedSegmentIndex)
    }
    
    override func layoutSubviews() {
        backgroundColor = .tertiarySystemBackground
    }
}
