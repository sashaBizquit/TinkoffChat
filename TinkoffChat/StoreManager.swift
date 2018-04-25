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
    
    lazy var mainContext: NSManagedObjectContext = {
        var mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        mainContext.parent = masterContext
        mainContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        mainContext.undoManager = nil
        
        return mainContext
    }()
    
    lazy var saveContext: NSManagedObjectContext = {
        var saveContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        saveContext.parent = mainContext
        saveContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        saveContext.undoManager = nil
        
        return saveContext
    }()
    
    
    fileprivate func performSave(context: NSManagedObjectContext, completionHandler: ((Bool)->Void)?) {
        
        guard context.hasChanges else {
            completionHandler?(true)
            return
        }
        context.perform { [weak self] in
            do {
                try context.save()
                guard let parent = context.parent else {
                    completionHandler?(true)
                    return
                }
                self?.performSave(context: parent, completionHandler: completionHandler)
            } catch  {
                print("Context save error:\(error)")
                completionHandler?(false)
            }

        }
    }
}

extension StoreManager {
//    convenience init(withModel model: NSManagedObjectModel, coordinator: NSPersistentStoreCoordinator, mainContext: NSManagedObjectContext, masterContext: NSManagedObjectContext, saveContext: NSManagedObjectContext) {
//        self.init()
//        self.managedObjectModel = model
//        self.persistantStoreCoordinator = coordinator
//        self.mainContext = mainContext
//        self.masterContext = masterContext
//        self.saveContext = saveContext
//    }
    
    func put(user: User, current: Bool) -> Bool {
        let currentUser: CDUser?
        if current {
            let appUser = AppUser.findOrInsertAppUser(in: mainContext)
            currentUser = appUser?.currentUser
        }
        else {
            currentUser = CDUser.findOrInsertAnyUser(withId: user.id, in: mainContext)
        }
        guard let newUser = currentUser else {
            return false
        }
        
        newUser.id = user.id
        newUser.name = user.name
        newUser.info = user.info
        newUser.photoPath = user.photoURL?.path
        save(completionHandler: nil)
        return true
    }
    
    func putNewConversation(withNetworkStatus online: Bool, lastDate date: Date, readStatus read: Bool, user: CDUser, text: String?, completionHandler: ((CDConversation)->Void)? = nil) {
        
        let conversationRequest = NSFetchRequest<CDConversation>(entityName: "CDConversation")
        saveContext.performAndWait { [weak self] in
            guard let strongSelf = self else {
                print("StoreManager уже нет")
                return
            }
            guard let conversationId = try? strongSelf.saveContext.fetch(conversationRequest).count + 1,
                let conversation = NSEntityDescription.insertNewObject(forEntityName: "CDConversation", into: strongSelf.saveContext) as? CDConversation  else {
                    print("Нет бесед/не смогли вставить")
                    return
            }
            conversation.id = Int64(conversationId)
            conversation.online = online
            conversation.hasUnreadMessages = read
            conversation.date = date
            conversation.text = text
            conversation.interlocutor = user
            completionHandler?(conversation)
        }
        
    }
    
    func putNewMessage(withText text: String, date: Date, hasSendToMe status: Bool, conversation: CDConversation, completionHandler: ((CDMessage)->Void)? = nil) {
        let messageRequest = NSFetchRequest<CDMessage>(entityName: "CDMessage")
        saveContext.performAndWait { [weak self] in
            guard let strongSelf = self else {
                print("StoreManager уже нет")
                return
            }
            guard let messageId = try? strongSelf.saveContext.fetch(messageRequest).count + 1,
                let message = NSEntityDescription.insertNewObject(forEntityName: "CDMessage", into: strongSelf.saveContext) as? CDMessage else {
                return
            }
            message.text = text
            message.id = String(messageId)
            message.date = date
            message.incoming = status
            message.conversation = conversation
            completionHandler?(message)
        }
    }
    
    func putNewUser(withId id: String?, name: String?, completionHandler: ((CDUser)->Void)? = nil) {
        let userRequest = NSFetchRequest<CDUser>(entityName: "CDUser")
        saveContext.performAndWait { [weak self] in
            guard let strongSelf = self else {
                print("StoreManager уже нет")
                return
            }
            guard let userId = try? strongSelf.saveContext.fetch(userRequest).count + 1,
                let user = NSEntityDescription.insertNewObject(forEntityName: "CDUser", into: strongSelf.saveContext) as? CDUser else {
                    print("Не смогли положить/посмотреть кол-во")
                    return
            }
            user.id =  id ?? String(-userId)
            user.name = name
            completionHandler!(user)
        }
    }
    
    func getUser(withId id: String) -> User? {
        if let anyUser = CDUser.findUser(withId: id, in: mainContext) {
            let userURL = anyUser.photoPath != nil ? URL(fileURLWithPath: anyUser.photoPath!) : nil
            return User(id: anyUser.id!,
                        name: anyUser.name,
                        photoURL: userURL,
                        info: anyUser.info)
        }
        
        return nil
    }
    
    func save(completionHandler: ((Bool)->Void)?) {
        performSave(context: saveContext, completionHandler: completionHandler)
    }
}

extension CDUser {
    
    static func findUser(withId id: String, in context: NSManagedObjectContext) -> CDUser? {
        var anyUser: CDUser?
        let fetchRequset = NSFetchRequest<CDUser>(entityName: "CDUser")
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
    
    static func findOrInsertAnyUser(withId id: String, in context: NSManagedObjectContext) -> CDUser? {
        var anyUser: CDUser? = findUser(withId: id, in: context)
        
        if anyUser == nil {
            anyUser = NSEntityDescription.insertNewObject(forEntityName: "CDUser", into: context) as? CDUser
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
            let currentUser = CDUser.findOrInsertAnyUser(withId: User.me.id, in: context)
            
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
