//
//  Results.swift
//  FlooidCoreData
//
//  Created by Martin Lalev on 24.08.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import CoreData

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
            self.postObserver(.initialized)
        }
        
    }
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.postObserver(.updated)
        }
    }
    public enum NotificationType: String {
        case initialized, updated, errored
        func asNotificationName() -> Notification.Name { return NSNotification.Name("coreDataResultsLayer-\(self.rawValue)-ObservationName") }
    }
    func postObserver(_ type: NotificationType) {
        NotificationCenter.default.post(name: type.asNotificationName(), object: self)
    }
    public func addObserver(_ observer:Any, selector: Selector, for type: NotificationType) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: type.asNotificationName(), object: self)
    }
    public func removeObserver(_ observer:Any, for type: NotificationType) {
        NotificationCenter.default.removeObserver(observer, name: type.asNotificationName(), object: self)
    }
}
