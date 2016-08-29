//
//  ThirdViewController.swift
//  SwiftNotificationCenterExample
//
//  Created by Mango on 16/5/5.
//  Copyright © 2016年 Mango. All rights reserved.
//

import Foundation
import SwiftNotificationCenter

class ThirddViewController: UIViewController, UpdateTitle {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotifyCenter.register(UpdateTitle.self, for: self)
    }
    
    func updateWithNewTitle(_ title: String) {
        titleLabel.text = title
    }
}
