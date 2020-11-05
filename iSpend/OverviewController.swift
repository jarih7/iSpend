//
//  ViewController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 28/10/2020.
//

import UIKit

class OverviewController: UIViewController {
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var lastMonthLabel: UILabel!
    @IBOutlet weak var monthSum: UILabel!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var lastWeekLabel: UILabel!
    @IBOutlet weak var weekSum: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monthView.layer.backgroundColor = UIColor.systemBlue.cgColor
        monthView.layer.cornerRadius = 10
        lastMonthLabel.textColor = .white
        monthSum.text = "2340"
        monthSum.textColor = .white
        
        weekView.layer.backgroundColor = UIColor.systemBlue.cgColor
        weekView.layer.cornerRadius = 10
        lastWeekLabel.textColor = .white
        weekSum.text = "270"
        weekSum.textColor = .white
    }
}

