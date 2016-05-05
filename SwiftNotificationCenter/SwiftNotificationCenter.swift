//
//  SwiftNotificationCenter.swift
//  SwiftNotificationCenter
//
//  Created by Mango on 16/5/5.
//  Copyright © 2016年 Mango. All rights reserved.
//

import Foundation

public class NotificationCenter {
    
    private static var observersDic = [String: Any]()
    
    private static let notificationQueue = dispatch_queue_create("com.swift.notification.center.dispatch.queue", DISPATCH_QUEUE_CONCURRENT)
    
    public static func register<T>(protocolType: T.Type, observer: T) {
        
        guard let object = observer as? AnyObject else {
            fatalError("expecting reference type but found value type: \(observer)")
        }
        
        let key = String(protocolType)
        safeSet(key: key, object: object)
    }
    
    public static func unregister<T>(protocolType: T.Type, observer: T) {
        if let object = observer as? AnyObject {
            let key = String(protocolType)
            safeRemove(key: key, object: object)
        }
    }
    
    public static func notify<T>(protocolType: T.Type, block: (observer: T) -> Void ) {
        
        let key = String(protocolType)
        guard let objectSet = safeGetObjectSet(key) else {
            return
        }
        
        for observer in objectSet {
            if let observer = observer as? T {
                block(observer: observer)
            }
        }
    }
}

private extension NotificationCenter {
    
    static func safeSet(key key: String, object: AnyObject) {
        dispatch_barrier_async(notificationQueue) {
            if var set = observersDic[key] as? WeakObjectSet<AnyObject> {
                set.addObject(object)
                observersDic[key] = set
            }else{
                observersDic[key] = WeakObjectSet([object])
            }
        }
    }
    
    static func safeRemove(key key: String, object: AnyObject) {
        dispatch_barrier_async(notificationQueue) {
            if var set = observersDic[key] as? WeakObjectSet<AnyObject> {
                set.removeObject(object)
                observersDic[key] = set
            }
        }
    }
    
    static func safeGetObjectSet(key: String) -> WeakObjectSet<AnyObject>? {
        var objectSet: WeakObjectSet<AnyObject>?
        dispatch_sync(notificationQueue) {
            objectSet = observersDic[key] as? WeakObjectSet<AnyObject>
        }
        return objectSet
    }
    
}