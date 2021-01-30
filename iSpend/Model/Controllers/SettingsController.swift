//
//  SettingsController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 13/11/2020.
//

import UIKit

class SettingsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let versionNumber: String = "0.9.8"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
        versionNumberLabel.text = versionNumber
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
        cell.segmentControl.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "SFCompactRounded-Medium", size: 13)!], for: .normal)
        cell.segmentControl.selectedSegmentIndex = DataManagement.sharedInstance.defaultIsIncoming ? 0 : 1
        return cell
    }
}
