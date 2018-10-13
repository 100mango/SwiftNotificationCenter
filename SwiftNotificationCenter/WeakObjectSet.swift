//
//  WeakObjectSet.swift
//  SwiftNotificationCenter
//
//  Created by Mango on 16/5/5.
//  Copyright © 2016年 Mango. All rights reserved.
//

import Foundation

struct WeakObject<T: AnyObject>: Equatable, Hashable {
    weak var object: T?
    init(_ object: T) {
        self.object = object
    }
    
    var hashValue: Int {
        if let object = self.object { return ObjectIdentifier(object).hashValue }
        else { return 0 }
    }
}

func == <T> (lhs: WeakObject<T>, rhs: WeakObject<T>) -> Bool {
    return lhs.object === rhs.object
}

struct WeakObjectSet<T: AnyObject>: Sequence {
    
    var objects: Set<WeakObject<T>>
    
    init() {
        self.objects = Set<WeakObject<T>>([])
    }
    
    init(_ object: T) {
        self.objects = Set<WeakObject<T>>([WeakObject(object)])
    }
    
    init(_ objects: [T]) {
        self.objects = Set<WeakObject<T>>(objects.map { WeakObject($0) })
    }
    
    var allObjects: [T] {
        #if swift(>=4.1)
            return objects.compactMap { $0.object }
        #else
            return objects.flatMap { $0.object }
        #endif
    }
    
    func contains(_ object: T) -> Bool {
        return self.objects.contains(WeakObject(object))
    }
    
    mutating func add(_ object: T) {
        var obs = self.objects.compactMap{ $0 }
        obs.append(WeakObject(object))
        self.objects = Set<WeakObject<T>>(obs)
    }
    
    mutating func add(_ objects: [T]) {
        var obs = self.objects.compactMap{ $0 }
        obs.append(contentsOf: objects.compactMap{ WeakObject($0) })
        self.objects = Set<WeakObject<T>>(obs)
    }
    
    mutating func remove(_ object: T) {
        self.objects.remove(WeakObject<T>(object))
    }
    
    mutating func remove(_ objects: [T]) {
        for object in objects {
            self.objects.remove(WeakObject<T>(object))
        }
    }
    
    func makeIterator() -> AnyIterator<T> {
        let objects = self.allObjects
        var index = 0
        return AnyIterator {
            defer { index += 1 }
            return index < objects.count ? objects[index] : nil
        }
    }
}
