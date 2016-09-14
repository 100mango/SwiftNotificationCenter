//
//  SecondViewController.swift
//  SwiftNotificationCenterExample
//
//  Created by Mango on 16/5/5.
//  Copyright © 2016年 Mango. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UpdateTitle {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Broadcaster.register(UpdateTitle.self, observer: self)
    }

    func updateWithNewTitle(title: String) {
        titleLabel.text = title
    }
}

