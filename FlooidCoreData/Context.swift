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
        context.automaticallyMergesChangesFromParent = true
    }
    
    public func perform(action: @escaping (_ backgroundContext: CoreDataContext, _ done: () -> Void) -> Void, then: @escaping () -> Void) {
        self.context.perform {
            action(self) {
                then()
            }
        }
    }
    
    public func executeInBackground(_ action: @escaping (CoreDataContext) -> Void) async {
        await withCheckedContinuation { continuation in
            self.perform(action: { context, done in
                context.transaction(action)
                done()
            }, then: continuation.resume)
        }
    }
    
    public func transaction(_ action:@escaping (CoreDataContext)->Void) {
        action(self)
        if self.context.hasChanges {
            try? self.context.save()
        }
    }
    
    public func add(_ object:PlainCoreDataObject) {
        self.context.insert(object)
    }
    
    public func delete(_ item:PlainCoreDataObject) {
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
