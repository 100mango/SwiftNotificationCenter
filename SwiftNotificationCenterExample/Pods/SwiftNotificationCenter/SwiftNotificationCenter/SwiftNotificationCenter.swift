//
//  SwiftNotificationCenter.swift
//  SwiftNotificationCenter
//
//  Created by Mango on 16/5/5.
//  Copyright © 2016年 Mango. All rights reserved.
//

import Foundation

public class NotifyCenter {
    
    private static var observersDic = [String: Any]()
    
    private static let notificationQueue = DispatchQueue(label: "com.swift.notification.center.dispatch.queue", attributes: .concurrent)
    
    public static func register<T>(_ protocolType: T.Type, for observer: T) {
        guard let object = observer as? AnyObject else {
            fatalError("expecting reference type but found value type: \(observer)")
        }
        
        let key = String(protocolType)
        safeSet(object, forKey: key)
    }
    
    public static func unregister<T>(_ protocolType: T.Type, for observer: T) {
        if let object = observer as? AnyObject {
            let key = String(protocolType)
            safeRemove(object, forKey: key)
        }
    }
    
    public static func notify<T>(_ protocolType: T.Type, closure: (observer: T) -> Void) {
        let key = String(protocolType)
        guard let objectSet = safeGetObjectSet(forKey: key) else { return }
        
        objectSet.forEach { if let observer = $0 as? T { closure(observer: observer) }}
    }
}

private extension NotifyCenter {
    
    static func safeSet(_ object: AnyObject, forKey key: String) {
        notificationQueue.async(flags: .barrier) {
            if var set = observersDic[key] as? WeakObjectSet<AnyObject> {
                set.add(object)
                observersDic[key] = set
            } else {
                observersDic[key] = WeakObjectSet([object])
            }
        }
    }
    
    static func safeRemove(_ object: AnyObject, forKey key: String) {
        notificationQueue.async(flags: .barrier) {
            if var set = observersDic[key] as? WeakObjectSet<AnyObject> {
                set.remove(object)
                observersDic[key] = set
            }
        }
    }
    
    static func safeGetObjectSet(forKey key: String) -> WeakObjectSet<AnyObject>? {
        var objectSet: WeakObjectSet<AnyObject>?
        notificationQueue.sync {
            objectSet = observersDic[key] as? WeakObjectSet<AnyObject>
        }
        return objectSet
    }
}
