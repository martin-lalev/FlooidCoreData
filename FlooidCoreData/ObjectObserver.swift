//
//  ObjectObserver.swift
//  FlooidCoreData
//
//  Created by Martin Lalev on 1.04.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataContextObserver<Managed> : NSObject {

    public struct Changes {
        public let deleted: Set<NSManagedObject>?
        public let updated: Set<NSManagedObject>?
        public let refreshed: Set<NSManagedObject>?
    }
    
    public private(set) var changes: Changes {
        didSet {
            NotificationCenter.default.post(name: self.name, object: self, userInfo: ["changes": changes])
        }
    }
    public let context: NSManagedObjectContext
    
    public init(in context: NSManagedObjectContext) {
        self.changes = Changes(deleted: nil, updated: nil, refreshed: nil)
        self.context = context
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(objectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: self.context)
    }
    public convenience init(in context: CoreDataContext) {
        self.init(in: context.context)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextObjectsDidChange, object: self.context)
    }
    
    @objc func objectsDidChange(_ notification: Notification) {
        self.changes = Changes(
            deleted: notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>,
            updated: notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
            refreshed: notification.userInfo?[NSRefreshedObjectsKey] as? Set<NSManagedObject>
        )
    }
    
    private let name = Notification.Name("CoreDataObjectUpdatedObserver_\(UUID().uuidString)")

    public func add(_ observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: self.name, object: self)
    }
    public func remove(_ observer: Any) {
        NotificationCenter.default.removeObserver(observer, name: self.name, object: self)
    }
    
    public func add(_ observer: @escaping (Changes) -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: self.name, object: self, queue: nil) { note in
            guard let model = note.userInfo?["changes"] as? Changes else { return }
            observer(model)
        }
    }
}
