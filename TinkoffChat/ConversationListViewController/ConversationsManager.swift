//
//  ConversationsManager.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 04.04.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import CoreData

enum SectionsNames: String {
    case Online = "Онлайн", Offline = "Офлайн"
}

class ConversationsManager: NSObject {
    
    private var fetchedResultController: NSFetchedResultsController<CDConversation>?
    private var mainContext: NSManagedObjectContext!
    private var saveContext: NSManagedObjectContext!
    private var communicator: MultipeerCommunicator!
    private weak var tableView: UITableView?

    init(with tableView: UITableView) {
        super.init()
        self.tableView = tableView
        self.setCommunicator()
        self.setupFRC()
        self.fetchData()
        self.setDefaultConversations()
    }
    
    func sendMessage(string: String, to userID: String, completionHandler: ((Bool, Error?) -> ())?) {
        communicator.sendMessage(string: string, to: userID, completionHandler: completionHandler)
    }
    
    // MARK: - Private
    
    private func setupFRC() {
        mainContext = AppDelegate.storeManager.mainContext
        saveContext = AppDelegate.storeManager.saveContext
        let fetchRequest = NSFetchRequest<CDConversation>(entityName: "CDConversation")
        let onlineSortDescriptor = NSSortDescriptor(key: "online", ascending: true)
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [onlineSortDescriptor, dateSortDescriptor]

        fetchedResultController = NSFetchedResultsController<CDConversation>(fetchRequest: fetchRequest,
                                                                      managedObjectContext: mainContext,
                                                                      sectionNameKeyPath: "online",
                                                                      cacheName: nil)
        fetchedResultController?.delegate = self
    }
    
    private func fetchData() {
        do {
            try fetchedResultController?.performFetch()
        } catch {
            print("Error - \(error), function:" + #function)
        }
    }
    
    private func setCommunicator() {
        communicator = MultipeerCommunicator()
        communicator.delegate = self
    }
    
    private func setDefaultConversations() {
        
        if (fetchedResultController?.sections?.count == 0 || fetchedResultController?.sections?.count == nil) {
            let boolArray = [false,false,false]
            outerloop: for status in boolArray {
                for readStatus in boolArray.reversed() {
                    guard let newChat = ConversationProvider.getNewConversation(online: status, andNotRead: readStatus) else {
                        print("Исчерпал диалоги")
                        break outerloop
                    }
                    
                    guard let date = newChat.date, let text = newChat.message else {
                            print("Не удалось положить пользователя/сообщение/беседу")
                            break outerloop
                    }
                    
                    AppDelegate.storeManager.putNewUser(withId: nil, name: newChat.name) {user in
                        AppDelegate.storeManager.putNewConversation(withNetworkStatus: status, lastDate: date, readStatus: readStatus, user: user, text: text) { conversation in
                            AppDelegate.storeManager.putNewMessage(withText: text, date: date, hasSendToMe: status, conversation: conversation)
                        }
                    }
                    
                }
            }
            AppDelegate.storeManager.save{ flag in
                if (flag) {
                    print("СОХРАНИЛ БОТОСООБЩЕНИЯ")
                } else {
                    print("НЕ СОХРАНИЛ БОТОСООБЩЕНИЯ")
                }
            }
        } else {
            print("Нашел диалоги в базе")
        }
        
    }
    
    func reloadSections(_ indexSet: IndexSet) {
        tableView?.reloadSections(indexSet, with: .right)
    }
    
    func getIdForIndexPath(_ indexPath: IndexPath) -> Int64? {
        guard let value = fetchedResultController?.object(at: indexPath) else {
            return nil
        }
        return value.id
    }
}

// MARK: - Table view data source
extension ConversationsManager : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sectionsCount = fetchedResultController?.sections?.count else {
            print("Не понял, сколько секций")
            return 2
        }
        return sectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultController?.sections else {
            print("Не понял, сколько элементов в секциях")
            return 0
        }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ConversationListCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "conversationIdentifier", for: indexPath) as? ConversationListCell {
            cell = dequeuedCell
        } else {
            cell = ConversationListCell()
        }
        
        if let conversation = fetchedResultController?.object(at: indexPath) {
            cell.name = conversation.interlocutor?.name ?? conversation.interlocutor?.id ?? "имечко"
            cell.hasUnreadMessages = conversation.hasUnreadMessages
            cell.online = conversation.online
            cell.message = conversation.text
            cell.date = conversation.date
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultController?.sections,
            sections.count == 1,
            sections[0].numberOfObjects > 0 {
            return fetchedResultController!.object(at: IndexPath(row: 0, section: 0)).online ? SectionsNames.Online.rawValue : SectionsNames.Offline.rawValue
        }
        return section == 0 ? SectionsNames.Online.rawValue : SectionsNames.Offline.rawValue
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension ConversationsManager : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .update:
            tableView?.reloadSections([sectionIndex], with: .automatic)
            break;
        case .insert:
            tableView?.insertSections([sectionIndex], with: .automatic)
            break;
        case .move:
            break;
        case .delete:
            tableView?.deleteSections([sectionIndex], with: .automatic)
            break;
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .update:
            if let indexPath = indexPath {
                tableView?.reloadRows(at: [indexPath], with: .automatic)
            }
            break;
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView?.insertRows(at: [newIndexPath], with: .automatic)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView?.deleteRows(at: [indexPath], with: .automatic)
            }
            
            if let newIndexPath = newIndexPath {
                tableView?.insertRows(at: [newIndexPath], with: .automatic)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView?.deleteRows(at: [indexPath], with: .automatic)
            }
            break;
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
}

// MARK: - CommunicatorDelegate
extension ConversationsManager : CommunicatorDelegate {
    
    func didFoundUser(userID: String, userName: String?) {
        let date = Date()
        let mainContext = AppDelegate.storeManager.mainContext
        let saveContext = AppDelegate.storeManager.saveContext
        let userRequest =  saveContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "UserWithId", substitutionVariables: ["ID": userID])
        if let result = try? mainContext.fetch(userRequest!) as? [CDUser],
            let user = result?.first {
            let conversationRequest =  saveContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "ConversationWithUser", substitutionVariables: ["ID": (user.id)!])
            
            if let results = try? saveContext.fetch(conversationRequest!) as? [CDConversation],
                let foundConversation = results?.first {
                foundConversation.text = ConversationListCell.noMessagesConst
                foundConversation.date = date
            } else {
                print("не вытащили беседу для существующего юзера")
            }
        } else {
            AppDelegate.storeManager.putNewUser(withId: userID, name: userName) {user in
                AppDelegate.storeManager.putNewConversation(withNetworkStatus: true, lastDate: date, readStatus: true, user: user, text: nil) {_ in
                    AppDelegate.storeManager.save {flag in
                        if (flag) {
                            print("Сохранил юзера")
                        } else {
                            print("Не сохранил юзера")
                        }
                    }
                }
            }
        }
    }
    
    func didLostUser(userID: String) {
        let saveContext = AppDelegate.storeManager.saveContext
        let userRequest =  saveContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "UserWithId", substitutionVariables: ["ID": userID])
        if let result = try? saveContext.fetch(userRequest!) as? [CDUser],
            let user = result?.first {
            let conversationRequest =  saveContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "ConversationWithUser", substitutionVariables: ["ID": (user.id)!])
            
            if let results = try? saveContext.fetch(conversationRequest!) as? [CDConversation],
                let foundConversation = results?.first {
                foundConversation.online = false
            } else {
                print("не вытащили юзера")
            }
        }
        AppDelegate.storeManager.save(completionHandler: {flag in if (flag) {print("Удалил Юзера")}})

    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        print("failedToStartBrowsingForUsers: \(error.localizedDescription)")
    }
    
    func failedToStartAdvertising(error: Error) {
        print("failedToStartAdvertising: \(error.localizedDescription)")
    }
    
    func didReceiveMessage(text: String, fromUserWithId: String, withId: String) {
        let date = Date()
        let mainContext = AppDelegate.storeManager.mainContext
        let userRequest =  mainContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "UserWithId", substitutionVariables: ["ID": fromUserWithId])
        if let result = try? mainContext.fetch(userRequest!) as? [CDUser],
            let user = result?.first {
            let conversationRequest =  mainContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "ConversationWithUser", substitutionVariables: ["ID": (user.id)!])
            
            guard let results = try? mainContext.fetch(conversationRequest!) as? [CDConversation],
                let foundConversation = results?.first else {
                    print("не вытащили беседу")
                    return
            }
            foundConversation.text = text
            foundConversation.date = date
            AppDelegate.storeManager.putNewMessage(withText: text, date: date, hasSendToMe: true, conversation: foundConversation) {_ in
                AppDelegate.storeManager.save{ flag in
                    if (flag) {
                        print("СОХРАНИЛ")
                    } else {
                        print("НЕ СОХРАНИЛ")
                    }
                }
            }
            
        }
    }
}
