//
//  Results.swift
//  FlooidCoreData
//
//  Created by Martin Lalev on 24.08.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import CoreData

private extension Notification.Name {
    static let coreDataResultsLayerInitializedObservationName = NSNotification.Name("coreDataResultsLayerInitializedObservationName")
    static let coreDataResultsLayerUpdatedObservationName = NSNotification.Name("coreDataResultsLayerUpdatedObservationName")
    static let coreDataResultsLayerErrorObservationName = NSNotification.Name("coreDataResultsLayerErrorObservationName")
}

public class CoreDataResults<Managed:CoreDataObject> : NSObject, NSFetchedResultsControllerDelegate {
    
    public var objects:[Managed]? {
        return self.results.fetchedObjects
    }
    private let results:NSFetchedResultsController<Managed>
    
    
    init(for fetchRequest:NSFetchRequest<Managed>, in context:CoreDataContext) {
        self.results = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context.context, sectionNameKeyPath: nil, cacheName: nil)
        super.init()
        self.results.delegate = self
        try? self.results.performFetch()
        DispatchQueue.main.async {
            self.postInitialized()
        }
        
    }
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.postUpdated()
        }
    }
    
    
    
    public func postInitialized() {
        NotificationCenter.default.post(name: .coreDataResultsLayerInitializedObservationName, object: self)
    }
    public func addInitialized(_ observer:Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: .coreDataResultsLayerInitializedObservationName, object: self)
    }
    public func removeInitialized(_ observer:Any) {
        NotificationCenter.default.removeObserver(observer, name: .coreDataResultsLayerInitializedObservationName, object: self)
    }
    
    public func postUpdated() {
        NotificationCenter.default.post(name: .coreDataResultsLayerUpdatedObservationName, object: self)
    }
    public func addUpdated(_ observer:Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: .coreDataResultsLayerUpdatedObservationName, object: self)
    }
    public func removeUpdated(_ observer:Any) {
        NotificationCenter.default.removeObserver(observer, name: .coreDataResultsLayerUpdatedObservationName, object: self)
    }
    
    public func postError() {
        NotificationCenter.default.post(name: .coreDataResultsLayerErrorObservationName, object: self)
    }
    public func addError(_ observer:Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: .coreDataResultsLayerErrorObservationName, object: self)
    }
    public func removeError(_ observer:Any) {
        NotificationCenter.default.removeObserver(observer, name: .coreDataResultsLayerErrorObservationName, object: self)
    }
}
