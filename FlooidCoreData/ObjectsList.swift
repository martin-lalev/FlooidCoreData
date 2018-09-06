//
//  CoreDataObjectsList.swift
//  FlooidCoreData
//
//  Created by Martin Lalev on 31.08.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation


public class CoreDataObjectsList<T: CoreDataObject> {
    private let set: NSMutableSet
    
    public init(for object: CoreDataObject, key: String) {
        self.set = object.mutableSetValue(forKey: key)
    }
    
    public var items: [T] {
        return self.set.allObjects as! [T]
    }
    public func append(_ item: T) {
        self.set.add(item)
    }
    public func append(_ items: [T]) -> Void {
        self.set.addObjects(from: items)
    }
    public func remove(_ item:T) -> Void {
        self.set.remove(item)
        
    }
    public func remove(_ items:[T]) -> Void {
        for item in items {
            self.set.remove(item)

        }
    }
    public func removeAll() -> Void {
        self.set.removeAllObjects()
    }
}
extension CoreDataObjectsList {
    @discardableResult
    public func replace(with items: [T]) -> [T] {
        let oldItems = self.items
        self.removeAll()
        self.append(items)
        return oldItems
    }
    @discardableResult
    public func replace(with items: Set<T>) -> [T] {
        return self.replace(with: Array(items))
    }
}

public class CoreDataObjectsReadOnlyList<T: CoreDataObject> {
    private let set: NSMutableSet
    
    public init(for object: CoreDataObject, key: String) {
        self.set = object.mutableSetValue(forKey: key)
    }
    
    public var items: [T] {
        return self.set.allObjects as! [T]
    }
}
