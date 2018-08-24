//
//  ThreadSafe.swift
//  FlooidCoreData
//
//  Created by Martin Lalev on 24.08.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import CoreData

public class ThreadSafeCoreDataObject<T: NSManagedObject> {
    let reference:NSManagedObjectID
    init(_ reference:NSManagedObjectID) {
        self.reference = reference
    }
    
    public func resolve(in context:CoreDataContext) -> T {
        return context.context.object(with: self.reference) as! T
    }
}
