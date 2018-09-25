//
//  Query.swift
//  FlooidCoreData
//
//  Created by Martin Lalev on 24.08.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataQuery<T:CoreDataObject> {
    var predicate: NSPredicate?
    var sortDescriptors: [NSSortDescriptor] = []
    
    let context: CoreDataContext
    init(for context: CoreDataContext) {
        self.context = context
    }
    
    public func filter(_ predicate: NSPredicate) -> Self {
        self.predicate = predicate
        return self
    }
    public func sort(_ sort: [NSSortDescriptor]) -> Self {
        self.sortDescriptors = sort
        return self
    }
    
    func asFetchRequest() -> NSFetchRequest<T> {
        let fetchRequest = NSFetchRequest<T>.init(entityName: T.entityName())
        fetchRequest.predicate = self.predicate
        fetchRequest.sortDescriptors = self.sortDescriptors
        
        
        
        
        
        
        return fetchRequest
    }
    
    public func results() -> CoreDataResults<T> {
        return CoreDataResults<T>(for:self.asFetchRequest(), in:self.context)
    }
    public func execute() -> [T] {
        return (try? self.context.context.fetch(self.asFetchRequest())) ?? []
    }
    public func forEach(_ iterator:(T)->Void) {
        for item in self.execute() {
            iterator(item)
        }
    }
}
