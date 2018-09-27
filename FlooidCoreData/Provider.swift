//
//  Repository.swift
//  FlooidCoreData
//
//  Created by Martin Lalev on 24.08.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation
import CoreData

open class CoreDataProvider {
    
    private let configuration: CoreDataConfiguration
    public let mainContext: CoreDataContext
    private let backgroundContext: CoreDataContext
    
    public init(configuration: CoreDataConfiguration) {
        self.configuration = configuration
        
        self.mainContext = CoreDataContext(NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        self.mainContext.context.parent = self.configuration.privateManagedObjectContext.context
        
        self.backgroundContext = CoreDataContext(NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType))
        self.backgroundContext.context.parent = self.mainContext.context
    }
    
    public func performInBackground(action:@escaping (_ backgroundContext: CoreDataContext, _ done: ()->Void)->Void, then: @escaping ()->Void) {
        self.backgroundContext.context.perform {
            action(self.backgroundContext) {
                DispatchQueue.main.async {
                    then()
                }
            }
        }
    }
    
}

public class CoreDataConfiguration {
    fileprivate let managedObjectModel: NSManagedObjectModel
    fileprivate let persistentStoreCoordinator: NSPersistentStoreCoordinator
    internal let privateManagedObjectContext: CoreDataContext
    public init(modelName:String, bundle:Bundle? = Bundle.main, inMemory:Bool) {
        guard let modelURL = bundle?.url(forResource: modelName, withExtension: "momd") else {
            fatalError("Unable to Find Data Model")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        
        self.managedObjectModel = managedObjectModel
        
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            if inMemory {
                try self.persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType,
                                                                       configurationName: nil,
                                                                       at: nil,
                                                                       options: [ NSInferMappingModelAutomaticallyOption : true,
                                                                                  NSMigratePersistentStoresAutomaticallyOption : true]
                )
            } else {
                try self.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                       configurationName: nil,
                                                                       at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                                                        .appendingPathComponent("\(modelName).sqlite"),
                                                                       options: [ NSInferMappingModelAutomaticallyOption : true,
                                                                                  NSMigratePersistentStoresAutomaticallyOption : true]
                )
            }
        } catch {
            fatalError("Unable to Load Persistent Store")
        }
        
        self.privateManagedObjectContext = CoreDataContext(NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType))
        
        self.privateManagedObjectContext.context.persistentStoreCoordinator = self.persistentStoreCoordinator
    }
}
