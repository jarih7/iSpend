//
//  TabBarController.swift
//  iSpend
//
//  Created by Jaroslav Hampejs on 02/11/2020.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}
