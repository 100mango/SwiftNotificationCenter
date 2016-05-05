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


struct WeakObjectSet<T: AnyObject>: SequenceType {
    
    var objects: Set<WeakObject<T>>
    
    init() {
        self.objects = Set<WeakObject<T>>([])
    }
    
    init(_ objects: [T]) {
        self.objects = Set<WeakObject<T>>(objects.map { WeakObject($0) })
    }
    
    var allObjects: [T] {
        return objects.flatMap { $0.object }
    }
    
    func contains(object: T) -> Bool {
        return self.objects.contains(WeakObject(object))
    }
    
    mutating func addObject(object: T) {
        self.objects.unionInPlace([WeakObject(object)])
    }
    
    mutating func addObjects(objects: [T]) {
        self.objects.unionInPlace(objects.map { WeakObject($0) })
    }
    
    mutating func removeObject(object: T) {
        self.objects.remove(WeakObject<T>(object))
    }
    
    mutating func removeObjects(objects: [T]) {
        for object in objects {
            self.objects.remove(WeakObject<T>(object))
        }
    }
    
    func generate() -> AnyGenerator<T> {
        let objects = self.allObjects
        var index = 0
        return AnyGenerator {
            defer { index += 1 }
            return index < objects.count ? objects[index] : nil
        }
    }
}