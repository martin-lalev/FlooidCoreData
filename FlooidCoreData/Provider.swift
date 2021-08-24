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
    
    public init(configuration: CoreDataConfiguration) {
        self.configuration = configuration
    }
    public var viewContext: CoreDataContext {
        CoreDataContext(self.configuration.container.viewContext)
    }
    public func newBackgroundContext() -> CoreDataContext {
        CoreDataContext(self.configuration.container.newBackgroundContext())
    }
}

public class CoreDataConfiguration {
    fileprivate let container: NSPersistentContainer
    public init(modelName:String, bundle:Bundle? = Bundle.main, inMemory:Bool, baseURL: URL? = nil) {
        guard let modelURL = bundle?.url(forResource: modelName, withExtension: "momd") else {
            fatalError("Unable to Find Data Model")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)

        if let storeURL = baseURL?.appendingPathComponent("\(modelName).sqlite") {
            let description = NSPersistentStoreDescription(url: storeURL)
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
    }
}
