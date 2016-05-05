//
//  FirstViewController.swift
//  SwiftNotificationCenterExample
//
//  Created by Mango on 16/5/5.
//  Copyright © 2016年 Mango. All rights reserved.
//

import UIKit
import SwiftNotificationCenter

class FirstViewController: UIViewController, UpdateTitle {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.register(UpdateTitle.self, observer: self)
    }

    func updateWithNewTitle(title: String) {
        titleLabel.text = title
    }
    
    @IBAction func updateTitle(sender: UIButton) {
        NotificationCenter.notify(UpdateTitle.self) {
            $0.updateWithNewTitle(self.textField.text ?? "")
            
        }
    }
    
}
