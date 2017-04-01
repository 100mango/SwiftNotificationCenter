//
//  SwiftNotificationCenter.swift
//  SwiftNotificationCenter
//
//  Created by Mango on 16/5/5.
//  Copyright © 2016年 Mango. All rights reserved.
//

import Foundation

public class Broadcaster {
    
    fileprivate static var observersDic = [String: Any]()
    
    fileprivate static let notificationQueue = DispatchQueue(label: "com.swift.notification.center.dispatch.queue", attributes: .concurrent)

    
    public static func register<T>(_ protocolType: T.Type, observer: T) {
        let key = "\(protocolType)"
        safeSet(key: key, object: observer as AnyObject)
    }
    
    public static func unregister<T>(_ protocolType: T.Type, observer: T) {
        let key = "\(protocolType)"
        safeRemove(key: key, object: observer as AnyObject)
    }
    
    public static func notify<T>(_ protocolType: T.Type, block: (T) -> Void ) {
        
        let key = "\(protocolType)"
        guard let objectSet = safeGetObjectSet(key: key) else {
            return
        }
        
        for observer in objectSet {
            if let observer = observer as? T {
                block(observer)
            }
        }
    }
}

private extension Broadcaster {
    
    static func safeSet(key: String, object: AnyObject) {
        notificationQueue.async(flags: .barrier) {
            if var set = observersDic[key] as? WeakObjectSet<AnyObject> {
                set.add(object)
                observersDic[key] = set
            }else{
                observersDic[key] = WeakObjectSet(object)
            }
        }
    }
    
    static func safeRemove(key: String, object: AnyObject) {
        notificationQueue.async(flags: .barrier) {
            if var set = observersDic[key] as? WeakObjectSet<AnyObject> {
                set.remove(object)
                observersDic[key] = set
            }
        }
    }
    
    static func safeGetObjectSet(key: String) -> WeakObjectSet<AnyObject>? {
        var objectSet: WeakObjectSet<AnyObject>?
        notificationQueue.sync {
            objectSet = observersDic[key] as? WeakObjectSet<AnyObject>
        }
        return objectSet
    }
    
}
