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
        NotifyCenter.register(UpdateTitle.self, for: self)
        NotifyCenter.register(UIKeyboardManage.self, for: self)
    }

    func updateWithNewTitle(_ title: String) {
        titleLabel.text = title
    }
    
    @IBAction func updateTitle(_ sender: UIButton) {
        NotifyCenter.notify(UpdateTitle.self) {
            $0.updateWithNewTitle(self.textField.text ?? "")
            
        }
    }
    
}

extension FirstViewController: UIKeyboardManage {
    func UIKeyboardWillShow(_ beginFrame: CGRect, endFrame: CGRect) {
        print("beginFrame:\(beginFrame)")
        print("endFrame:\(endFrame)")
    }
}
