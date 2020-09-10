//
//  ObjectObserver.swift
//  FlooidCoreData
//
//  Created by Martin Lalev on 1.04.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataObjectObserver<Managed:CoreDataObject> : NSObject {

    public enum Action { case deleted, updated }
    
    public var object: Managed
    private let action: Action
    
    private var actionKey: String {
        switch self.action {
        case .deleted:
            return NSDeletedObjectsKey
        case .updated:
            return NSUpdatedObjectsKey
        }
    }

    public init(for object: Managed, action: Action) {
        self.object = object
        self.action = action
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(objectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: self.object.managedObjectContext!)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextObjectsDidChange, object: self.object.managedObjectContext!)
    }
    
    @objc func objectsDidChange(_ notification: Notification) {
        guard (notification.userInfo?[self.actionKey] as? Set<NSManagedObject> ?? []).contains(where: { $0 == self.object }) else { return }
        NotificationCenter.default.post(name: self.name, object: self.object, userInfo: nil)
    }
    
    private lazy var name: Notification.Name = .init("CoreDataObjectUpdatedObserver_\(object.objectID.description)")

    public func add(_ observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: self.name, object: self.object)
    }
    public func remove(_ observer: Any) {
        NotificationCenter.default.removeObserver(observer, name: self.name, object: self.object)
    }
}
