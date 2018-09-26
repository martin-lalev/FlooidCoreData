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
    var predicates: [NSPredicate] = []
    var sortDescriptors: [NSSortDescriptor] = []
    
    let context: CoreDataContext
    init(for context: CoreDataContext) {
        self.context = context
    }
    
    public func filter(_ predicates: [NSPredicate]) -> Self {
        self.predicates.append(contentsOf: predicates)
        return self
    }
    public func filter(_ predicates: NSPredicate ...) -> Self {
        return self.filter(predicates)
    }
    public func sort(_ sort: [NSSortDescriptor]) -> Self {
        self.sortDescriptors.append(contentsOf: sort)
        return self
    }
    public func sort(_ sort: NSSortDescriptor ...) -> Self {
        return self.sort(sort)
    }
    
    func asFetchRequest() -> NSFetchRequest<T> {
        let fetchRequest = NSFetchRequest<T>.init(entityName: T.entityName())
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: self.predicates)
        fetchRequest.sortDescriptors = self.sortDescriptors
        
        
        
        return fetchRequest
    }
    
    public func results() -> CoreDataResults<T> {
        return CoreDataResults<T>(for:self.asFetchRequest(), in:self.context)
    }
    public func execute() -> [T] {
        return (try? self.context.context.fetch(self.asFetchRequest())) ?? []
    }
}
