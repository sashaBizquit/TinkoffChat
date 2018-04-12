//
//  StoreManager.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 12.04.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import Foundation
import CoreData

class StoreManager {
    var storeURL: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("MyStore.sqlite")
    }
    let dataModelName = "MyDataModel"
    let dataModelExtension = "momd"
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: dataModelName, withExtension: dataModelExtension)!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistantStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: storeURL,
                                               options: nil)
        } catch {
            assert(false, "Error adding store: \(error)")
        }
        return coordinator
    }()
    
    lazy var masterContext: NSManagedObjectContext = {
        var masterContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        masterContext.persistentStoreCoordinator = persistantStoreCoordinator
        masterContext.mergePolicy = NSOverwriteMergePolicy
        
        return masterContext
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        var mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        mainContext.parent = masterContext
        mainContext.mergePolicy = NSOverwriteMergePolicy
        
        return mainContext
    }()
    
    lazy var saveContext: NSManagedObjectContext = {
        var saveContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        saveContext.parent = mainContext
        saveContext.mergePolicy = NSOverwriteMergePolicy
        
        return saveContext
    }()
    
    
    public func performSave(context:NSManagedObjectContext, completionHandler: (()->Void)?) {
        guard !context.hasChanges else {
            completionHandler?()
            return
        }
        context.perform { [weak self] in
            do {
                try context.save()
            } catch  {
                print("Context save error:\(error)")
            }
            guard let parent = context.parent else {
                completionHandler?()
                return
            }
            self?.performSave(context: parent, completionHandler: completionHandler)
        }
    }

    
    static func findOrInsertAppUser(in context: NSManagedObjectContext) -> AppUser? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            assert(false, "Model is not avaliable in context!")
            return nil
        }
        //AppUser(
        var appUser: AppUser?
        guard let fetchRequset = AppUser.fetchRequestAppUser(model: model) else {
            assert(false, "No such request!")
            return nil
        }
        do {
            let results = try context.fetch(fetchRequset)
            assert(results.count < 2, "Multiple AppUsers found!")
            if let foundUser = results.first {
                appUser = foundUser
            }
        } catch {
            print("Failed to fetch AppUser: \(error)")
        }
        if appUser == nil {
            appUser = AppUser.insertAppUser(in: context)
        }
        return appUser
    }
}

extension StoreManager {
    func save(user: User) {
        guard let anyUser = NSEntityDescription.insertNewObject(forEntityName: "AnyUser", into: saveContext) as? AnyUser else {
            assert(false, "Can't create AnyUser!")
            return
        }
        
        anyUser.id = user.id
        anyUser.info = user.info
        anyUser.name = user.name
        anyUser.photoURL = user.photoURL?.absoluteString
        
        self.performSave(context: saveContext, completionHandler: nil)
    }
}

extension AppUser {
    
    static func insertAppUser(in context: NSManagedObjectContext) -> AppUser? {
        guard let appUser = NSEntityDescription.insertNewObject(forEntityName: "AppUser", into: context) as? AppUser else {
            return nil
        }
        if appUser.currentUser == nil {
            
        }
        return appUser
    }
    
    static func fetchRequestAppUser(model: NSManagedObjectModel) -> NSFetchRequest<AppUser>? {
        let requestName = "AppUserRequest"
        guard let fetchRequest = model.fetchRequestTemplate(forName: requestName) as? NSFetchRequest<AppUser> else {
            assert(false, "No request with name: \(requestName)")
            return nil
        }
        return fetchRequest
    }
}
