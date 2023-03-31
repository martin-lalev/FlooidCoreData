//
//  File.swift
//  
//
//  Created by Martin Lalev on 31/03/2023.
//

import Foundation

public protocol QueryableModel {
    associatedtype Filter
    associatedtype Sort
    static func asSortDescriptor(_ sort: Sort) -> NSSortDescriptor
    static func asPredicate(_ filter: Filter) -> NSPredicate
}

extension QueryableModel where Self: PlainCoreDataObject {
    public static func query(
        in context: CoreDataContext,
        filter: @autoclosure () -> [Filter],
        sort: @autoclosure () -> [Sort]
    ) -> CoreDataQuery<Self> {
        Self.query(in: context)
            .filter(filter().map { Self.asPredicate($0) })
            .sort(sort().map { Self.asSortDescriptor($0) })
    }
    
    public static func results(
        in context: CoreDataContext,
        filter: @autoclosure () -> [Filter],
        sort: @autoclosure () -> [Sort]
    ) -> CoreDataResults<Self> {
        Self.query(in: context, filter: filter(), sort: sort()).results()
    }
}
