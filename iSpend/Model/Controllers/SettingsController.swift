//
//  SettingsController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 13/11/2020.
//

import UIKit

class SettingsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let appName: String = "iSpend™"
    let versionNumber: String = "0.9.4"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupTableView()

        appNameLabel.text = appName
        appNameLabel.textColor = .secondaryLabel
        versionLabel.textColor = .secondaryLabel
        versionNumberLabel.text = versionNumber
        versionNumberLabel.textColor = .secondaryLabel
        copyrightLabel.textColor = .secondaryLabel
    }
    
    func setupTableView() {
        tableView.automaticallyAdjustsScrollIndicatorInsets = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsViewCell", for: indexPath) as! SettingsViewCell
        cell.label.text = "Default transaction type"
        cell.segmentControl.setTitle("Incoming", forSegmentAt: 0)
        cell.segmentControl.setTitle("Outgoing", forSegmentAt: 1)
        cell.segmentControl.selectedSegmentIndex = DataManagement.sharedInstance.defaultIsIncoming ? 0 : 1
        return cell
    }
}
