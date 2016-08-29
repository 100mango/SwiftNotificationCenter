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
    
    func updateWithNewTitle(_ title: String)
    
}

protocol UIKeyboardManage {
    func UIKeyboardWillShow(_ beginFrame: CGRect, endFrame: CGRect)
}


class UIKeyboardSystemNotifictionMediator {
    
    private lazy var __once: () = {
            NotificationCenter.default.addObserver(mediator, selector: #selector(UIKeyboardSystemNotifictionMediator.handleKeyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        }()
    
    static let mediator = UIKeyboardSystemNotifictionMediator()

    
    @objc func handleKeyboardNotification(_ notification: Notification) {
        guard notification.name == NSNotification.Name.UIKeyboardWillShow
            else { return }
        
        guard let beginFrame = ((notification as NSNotification)
            .userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue()
            else { return }
        
        guard let endFrame = ((notification as NSNotification)
            .userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue()
            else { return }
        
        NotifyCenter.notify(UIKeyboardManage.self) {
            $0.UIKeyboardWillShow(beginFrame, endFrame: endFrame)
        }
    }
    
    static func register() {
        let once: () = {
            NotificationCenter.default.addObserver(mediator, selector: #selector(UIKeyboardSystemNotifictionMediator.handleKeyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        }()
        _ = once
    }
    
}
