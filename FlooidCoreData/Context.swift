//
//  Context.swift
//  FlooidCoreData
//
//  Created by Martin Lalev on 24.08.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import CoreData

public final class CoreDataContext {
    let context: NSManagedObjectContext
    init(_ context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func transaction(_ action:@escaping (CoreDataContext)->Void) {
        
        action(self)
        self.context.cascadeSave()
    }
    
    public func add(_ object:CoreDataObject) {
        self.context.insert(object)
    }
    
    public func delete(_ item:CoreDataObject) {
        self.context.delete(item)
    }
    
}

extension CoreDataQuery {
    public func deleteAll() {
        for item in self.execute() {
            self.context.delete(item)
        }
    }
    
}

extension NSManagedObjectContext {
    func cascadeSave() {
        try? self.save()
        if let parent = self.parent {
            parent.performAndWait {
                parent.cascadeSave()
            }
        }
    }
}
