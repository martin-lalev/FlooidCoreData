//
//  Object.swift
//  FlooidCoreData
//
//  Created by Martin Lalev on 24.08.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import CoreData

public protocol DataObjectProtocol: class {
    static func entityName() -> String
    static func idKey() -> String
}

public extension DataObjectProtocol where Self: NSManagedObject {
    
    public func threadSafe() -> ThreadSafeCoreDataObject<Self> {
        return ThreadSafeCoreDataObject(self.objectID)
    }
    
    public static func query() -> CoreDataQuery<Self> {
        return CoreDataQuery()
    }
    
    public static func object(forID id: String, in context:CoreDataContext) -> Self? {
        return Self.query().filter(NSPredicate(format: "%@ = %@", self.idKey(), id)).execute(in: context).first
    }
    
    public static func create(forID id: String, in context:CoreDataContext) -> Self {
        let item = Self(entity: NSEntityDescription.entity(forEntityName: Self.entityName(), in: context.context)!, insertInto: context.context)
        item.setValue(id, forKey: self.idKey())
        
        return item
    }
    
    public static func create(in context:CoreDataContext) -> Self {
        let item = Self(entity: NSEntityDescription.entity(forEntityName: Self.entityName(), in: context.context)!, insertInto: context.context)
        context.add(item)
        return item
    }
    
    public static func findOrCreate(in context:CoreDataContext, id: String) -> Self {
        return self.object(forID: id, in: context) ?? self.create(forID: id, in: context)
    }
    
}

public typealias CoreDataObject = NSManagedObject & DataObjectProtocol
