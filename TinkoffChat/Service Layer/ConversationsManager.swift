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
    private var storeManager: StoreManagerProtocol
    private var communicator: MultipeerCommunicator?
    private weak var tableView: UITableView?

    init(with tableView: UITableView, andManager manager: StoreManagerProtocol) {
        self.storeManager = manager
        self.tableView = tableView
        super.init()
        self.setCommunicator()
        self.setupFRC()
        self.fetchData()
        //self.setDefaultConversations()
        self.prepareStoredConversations()
    }
    
    func sendMessage(string: String, to userID: String, completionHandler: ((Bool, Error?) -> ())?) {
        communicator?.sendMessage(string: string, to: userID, completionHandler: completionHandler)
    }
    
    // MARK: - Private
    
    private func setupFRC() {
        let fetchRequest = NSFetchRequest<CDConversation>(entityName: "CDConversation")
        let onlineSortDescriptor = NSSortDescriptor(key: "online", ascending: true)
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [onlineSortDescriptor, dateSortDescriptor]
        fetchedResultController = NSFetchedResultsController<CDConversation>(fetchRequest: fetchRequest,
                                                                      managedObjectContext: storeManager.mainContext,
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
        startCommunicating()
    }
    
    func startCommunicating() {
        communicator?.delegate = self
    }
    
    private func prepareStoredConversations() {
        if (fetchedResultController?.sections?.count != 0 && fetchedResultController?.sections?.count != nil) {
            guard let objects = fetchedResultController?.fetchedObjects else {
                return
            }
            for object in objects {
                object.online = false
            }
            return
        }
    }
    
    private func setDefaultConversations() {
        outerloop: for status in [false,false,false] {
            for readStatus in [false,true,true] {
                guard let newChat = ConversationProvider.getNewConversation(online: status, andNotRead: readStatus) else {
                    print("Исчерпал диалоги: newChat == nil")
                    break outerloop
                }
                let text = newChat.message
                guard let date = newChat.date else {
                        print("Пользователь без даты")
                        break outerloop
                }
                storeManager.findOrInsertUser(withId: nil, name: newChat.name) { [weak storeManager] user in
                    
                    guard let id = user.id,
                        let strongManager = storeManager else {
                        assert(false, "storeManager is nil")
                    }
                    
                    strongManager.findOrInsertConversation(withId: id)
                    {
                        [weak storeManager] conversation in
                        conversation.online = status
                        conversation.hasUnreadMessages = readStatus
                        conversation.interlocutor = user
                        conversation.text = text
                        conversation.date = date
                        if let unwrapedText = text {
                            storeManager?.putNewMessage(withText: unwrapedText, date: date, hasSendToMe: status, conversation: conversation)
                        }
                    }
                }
            }
        }
        self.storeManager.save{ flag in
            if (!flag) {
                print("НЕ СОХРАНИЛ БОТОСООБЩЕНИЯ")
            }
        }
    }
    
    func reloadSections(_ indexSet: IndexSet) {
        tableView?.reloadSections(indexSet, with: .right)
    }
    
    func getIdForIndexPath(_ indexPath: IndexPath) -> Int64? {
        return fetchedResultController?.object(at: indexPath).id
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
            cell.name = conversation.interlocutor?.name ?? conversation.interlocutor?.id ?? "No-id user"
            cell.hasUnreadMessages = conversation.hasUnreadMessages
            cell.online = conversation.online
            cell.message = conversation.text
            cell.date = conversation.date
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let controller = fetchedResultController,
            let sections = controller.sections,
            sections.count == 1,
            sections[0].numberOfObjects > 0 {
            
            return controller.object(at: IndexPath(row: 0, section: 0)).online ? SectionsNames.Online.rawValue : SectionsNames.Offline.rawValue
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
            tableView?.reloadSections([sectionIndex], with: .bottom )
            break;
        case .insert:
            tableView?.insertSections([sectionIndex], with: .bottom)
            break;
        case .move:
            break;
        case .delete:
            tableView?.deleteSections([sectionIndex], with: .bottom)
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
        
        if let id = storeManager.getUser(withId: userID)?.id {
            storeManager.findOrInsertConversation(withId: id) { conversation in
                conversation.online = true
                //conversation.text = ConversationListCell.noMessagesConst
                //conversation.date = date
            }
        } else {
            storeManager.findOrInsertUser(withId: userID, name: userName) { [weak storeManager] user in
                storeManager?.findOrInsertConversation(withId: user.id) { conversation in
                    conversation.date = date
                    conversation.online = true
                    conversation.hasUnreadMessages = true
                    conversation.interlocutor = user
                    //conversation.text = ConversationListCell.noMessagesConst
                }
            }
        }
        storeManager.save(completionHandler: nil)
        NotificationCenter.default.post(name: .didFoundUser, object: nil)
    }
    
    
    func didLostUser(userID: String) {
        storeManager.findOrInsertConversation(withId: userID) { conversation in
            conversation.online = false
        }
        storeManager.save(completionHandler: nil)
        NotificationCenter.default.post(name: .didLostUser, object: nil)
    }
    
    func didReadConversation<T>(withId id: T) {
        storeManager.findOrInsertConversation(withId: id) { conversation in
            conversation.hasUnreadMessages = false
        }
        storeManager.save(completionHandler: nil)
    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        print("failedToStartBrowsingForUsers: \(error.localizedDescription)")
    }
    
    func failedToStartAdvertising(error: Error) {
        print("failedToStartAdvertising: \(error.localizedDescription)")
    }
    
    func didReceiveMessage(text: String, fromUserWithId id: String, withMessageId messageId: String) {
        let date = Date()
        storeManager.findOrInsertConversation(withId: id) { [weak storeManager] conversation in
            guard let manager = storeManager else {
                assert(false, "No manager found")
            }
            conversation.text = text
            conversation.date = date
            conversation.hasUnreadMessages = true
            manager.putNewMessage(withText: text, date: date, hasSendToMe: true, conversation: conversation) { message in
                message.id = messageId
            }
        }
        storeManager.save(completionHandler: nil)
    }
}
