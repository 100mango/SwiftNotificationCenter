//
//  FirstViewController.swift
//  SwiftNotificationCenterExample
//
//  Created by Mango on 16/5/5.
//  Copyright © 2016年 Mango. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UpdateTitle {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Broadcaster.register(UpdateTitle.self, observer: self)
        Broadcaster.register(UIKeyboardManage.self, observer: self)
    }

    func updateWithNewTitle(title: String) {
        titleLabel.text = title
    }
    
    @IBAction func updateTitle(sender: UIButton) {
        Broadcaster.notify(UpdateTitle.self) {
            $0.updateWithNewTitle(title: self.textField.text ?? "")
        }
    }
    
}

extension FirstViewController: UIKeyboardManage {
    func UIKeyboardWillShow(beginFrame: CGRect, endFrame: CGRect) {
        print("beginFrame:\(beginFrame)")
        print("endFrame:\(endFrame)")
    }
}
