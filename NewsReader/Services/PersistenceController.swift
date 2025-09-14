//
//  PersistenceController.swift
//  NewsReader
//
//  Created by Sandeep on 14/09/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ReaderModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { desc, error in
            if let error = error { fatalError("Unresolved error \(error)") }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    var viewContext: NSManagedObjectContext { container.viewContext }
    
    func saveContext() {
        let ctx = container.viewContext
        if ctx.hasChanges {
            do { try ctx.save() } catch { print("CoreData rror: \(error)") }
        }
    }
}
