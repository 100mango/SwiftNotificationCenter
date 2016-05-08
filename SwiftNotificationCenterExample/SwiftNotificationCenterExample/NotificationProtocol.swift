//
//  NotificationProtocol.swift
//  SwiftNotificationCenterExample
//
//  Created by Mango on 16/5/5.
//  Copyright © 2016年 Mango. All rights reserved.
//

import UIKit
import SwiftNotificationCenter

protocol UpdateTitle: class {
    
    func updateWithNewTitle(title: String)
    
}

protocol UIKeyboardManage {
    func UIKeyboardWillShow(beginFrame: CGRect, endFrame: CGRect)
}


class UIKeyboardSystemNotifictionMediator {
    
    static let mediator = UIKeyboardSystemNotifictionMediator()

    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        guard notification.name == UIKeyboardWillShowNotification
            else { return }
        
        guard let beginFrame = (notification
            .userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
            else { return }
        
        guard let endFrame = (notification
            .userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            else { return }
        
        NotificationCenter.notify(UIKeyboardManage.self) {
            $0.UIKeyboardWillShow(beginFrame, endFrame: endFrame)
        }
    }
    
    static func register() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            NSNotificationCenter.defaultCenter().addObserver(mediator, selector: #selector(UIKeyboardSystemNotifictionMediator.handleKeyboardNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        }
    }
    
}