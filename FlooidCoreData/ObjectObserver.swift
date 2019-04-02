//
//  ObjectObserver.swift
//  FlooidCoreData
//
//  Created by Martin Lalev on 1.04.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataObjectDeletedObserver<Managed:CoreDataObject> : NSObject {
    
    private var object:Managed
    private let callback: () -> Void
    
    public init(for object:Managed, callback: @escaping () -> Void) {
        self.object = object
        self.callback = callback
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(objectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: self.object.managedObjectContext!)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextObjectsDidChange, object: self.object.managedObjectContext!)
    }
    
    @objc func objectsDidChange(_ notification: Notification) {
        guard (notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? []).contains(self.object) else { return }
        self.callback()
    }
}
public class CoreDataObjectUpdatedObserver<Managed:CoreDataObject> : NSObject {
    private var object:Managed
    private let callback: ([String: (old: Any?, new: Any?)]) -> Void
    
    public init(for object:Managed, callback: @escaping ([String: (old: Any?, new: Any?)]) -> Void) {
        self.object = object
        self.callback = callback
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(objectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: self.object.managedObjectContext!)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextObjectsDidChange, object: self.object.managedObjectContext!)
    }
    
    @objc func objectsDidChange(_ notification: Notification) {
        if let updated = (notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? []).first(where: { $0 == self.object }) {
            self.callback(updated.changedValues().reduce(into: [:]) { $0[$1.key] = (old:$1.value,new:updated.value(forKey: $1.key)) })
        }
    }
}





extension DataObjectProtocol where Self: NSManagedObject {
    public static func deleteObserver(for id: String, in context:CoreDataContext, callback: @escaping () -> Void) -> CoreDataObjectDeletedObserver<Self>? {
        return Self.object(forID: id, in: context)?.deleteObserver(callback: callback)
    }
    public func deleteObserver(callback: @escaping () -> Void) -> CoreDataObjectDeletedObserver<Self> {
        return CoreDataObjectDeletedObserver(for: self, callback: callback)
    }

    public static func updateObserver(for id: String, in context:CoreDataContext, callback: @escaping ([String: (old: Any?, new: Any?)]) -> Void) -> CoreDataObjectUpdatedObserver<Self>? {
        return Self.object(forID: id, in: context)?.updateObserver(callback: callback)
    }
    public func updateObserver(callback: @escaping ([String: (old: Any?, new: Any?)]) -> Void) -> CoreDataObjectUpdatedObserver<Self> {
        return CoreDataObjectUpdatedObserver(for: self, callback: callback)
    }
}
