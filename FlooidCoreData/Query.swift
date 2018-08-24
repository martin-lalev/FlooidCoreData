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
    
    public func filter(_ predicate: NSPredicate) -> Self {
        self.predicate = predicate
        return self
    }
    public func sort(_ sort: [NSSortDescriptor]) -> Self {
        self.sortDescriptors = sort
        return self
    }
    
    func asFetchRequest(in context:CoreDataContext) -> NSFetchRequest<T> {
        let fetchRequest = NSFetchRequest<T>.init(entityName: T.entityName())
        fetchRequest.predicate = self.predicate
        fetchRequest.sortDescriptors = self.sortDescriptors
        
        
        
        
        
        
        return fetchRequest
    }
    
    public func results(for context:CoreDataContext) -> CoreDataResults<T> {
        return CoreDataResults<T>(for:self.asFetchRequest(in: context), in:context)
    }
    public func execute(in context:CoreDataContext) -> [T] {
        return (try? context.context.fetch(self.asFetchRequest(in: context))) ?? []
    }
    public func forEach(in context:CoreDataContext, _ iterator:(T)->Void) {
        for item in self.execute(in: context) {
            iterator(item)
        }
    }
}
