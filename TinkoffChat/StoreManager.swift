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
    private var storeURL: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("MyStore.sqlite")
    }
    private let dataModelName = "Storage"
    private let dataModelExtension = "momd"
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: dataModelName, withExtension: dataModelExtension)!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var persistantStoreCoordinator: NSPersistentStoreCoordinator = {
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
    
    private lazy var masterContext: NSManagedObjectContext = {
        var masterContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        masterContext.persistentStoreCoordinator = persistantStoreCoordinator
        masterContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        masterContext.undoManager = nil
        
        return masterContext
    }()
    
    private lazy var mainContext: NSManagedObjectContext = {
        var mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        mainContext.parent = masterContext
        mainContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        mainContext.undoManager = nil
        
        return mainContext
    }()
    
    private lazy var saveContext: NSManagedObjectContext = {
        var saveContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        saveContext.parent = mainContext
        saveContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        saveContext.undoManager = nil
        
        return saveContext
    }()
    
    
    fileprivate func performSave(context: NSManagedObjectContext, completionHandler: (()->Void)?) {
        
        guard context.hasChanges else {
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
}

extension StoreManager {
    func put(user: User, current: Bool) -> Bool {
        let currentUser: AnyUser?
        if current {
            
            let appUser = AppUser.findOrInsertAppUser(in: saveContext)
            currentUser = appUser?.currentUser
        }
        else {
            currentUser = AnyUser.findOrInsertAnyUser(withId: user.id, in: saveContext)
        }
        
        guard let newUser = currentUser else {
            return false
        }
        
        newUser.id = user.id
        newUser.name = user.name
        newUser.info = user.info
        newUser.photoPath = user.photoURL?.path
        return true
    }
    
    func getUser(withId id: String) -> User? {
        if let anyUser = AnyUser.findUser(withId: id, in: mainContext) {
            let userURL = anyUser.photoPath != nil ? URL(fileURLWithPath: anyUser.photoPath!) : nil
            return User(id: anyUser.id!,
                        name: anyUser.name,
                        photoURL: userURL,
                        info: anyUser.info)
        }
        
        return nil
    }
    
    func save(completionHandler: (()->Void)?) {
        performSave(context: saveContext, completionHandler: completionHandler)
    }
}

extension AnyUser {
    
    static func findUser(withId id: String, in context: NSManagedObjectContext) -> AnyUser? {
        var anyUser: AnyUser?
        let fetchRequset = NSFetchRequest<AnyUser>(entityName: "AnyUser")
        fetchRequset.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(fetchRequset)
            assert(results.count < 2, "Multiple AnyUsers found with id = \(id)!")
            if let foundUser = results.first {
                anyUser = foundUser
            }
            
        } catch {
            print("Failed to fetch AnyUser with id = \(id): \(error)")
        }
        return anyUser
    }
    
    static func findOrInsertAnyUser(withId id: String, in context: NSManagedObjectContext) -> AnyUser? {
        var anyUser: AnyUser? = findUser(withId: id, in: context)
        
        if anyUser == nil {
            anyUser = NSEntityDescription.insertNewObject(forEntityName: "AnyUser", into: context) as? AnyUser
            print(context.hasChanges)
            
            anyUser?.id = id
        }
        
        return anyUser
    }
}

extension AppUser {
    
    static func findOrInsertAppUser(in context: NSManagedObjectContext) -> AppUser? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            assert(false, "Model is not avaliable in context!")
            return nil
        }
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
    
    static func insertAppUser(in context: NSManagedObjectContext) -> AppUser? {
        guard let appUser = NSEntityDescription.insertNewObject(forEntityName: "AppUser", into: context) as? AppUser else {
            return nil
        }
        
        if appUser.currentUser == nil {
            let currentUser = AnyUser.findOrInsertAnyUser(withId: User.me.id, in: context)
            
            appUser.currentUser = currentUser
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
