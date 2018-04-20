//
//  Conversation.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 04.04.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import Foundation
import CoreData

struct Message {
    var text: String?
    var date: Date?
    var sender: User
    var isIncoming: Bool
}

struct User {
    var id: String
    var info: String?
    var photoURL: URL?
    var name: String?
    static var me: User  = {
        return User(id: MultipeerCommunicator.myPeerId.displayName, name: MultipeerCommunicator.userName)
    }()
    init(id newId: String, name newName: String?) {
        id = newId
        name = newName
        info = nil
        photoURL = nil
    }
    init(id newId: String, name newName: String?, photoURL url: URL?, info newInfo: String?) {
        id = newId
        name = newName
        info = newInfo
        photoURL = url
    }
}

class Conversation: NSObject {
    
    private var fetchedResultController: NSFetchedResultsController<CDMessage>?
    private var mainContext: NSManagedObjectContext!
    private var saveContext: NSManagedObjectContext!
    
    var interlocutor: User!
    var online: Bool {
        let conversationRequest =  saveContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "ConversationWithUser", substitutionVariables: ["ID": interlocutor.id])
        
        if let results = try? saveContext.fetch((conversationRequest!)) as? [CDConversation],
            let foundConversation = results?.first {
            return foundConversation.online
        }
        return false
    }
//    var isUnread: Bool = true
//    var messages: [Message]?
//    var lastMessage: Message? {
//        return messages?.last
//    }
//    var lastActivityDate: Date!
    
    weak var tableView: UITableView?
    private weak var manager: ConversationsManager?
    
    init(withManager manager: ConversationsManager?, userId id: String) {
        super.init()
//        self.interlocutor = user
//        self.online = status
        self.manager = manager
        setupFRC(withId: id)
        fetchData()
    }
    
    
    // MARK: - Private
    
    private func setupFRC(withId id: String) {
        mainContext = AppDelegate.storeManager.mainContext
        saveContext = AppDelegate.storeManager.saveContext
        let userRequest =  mainContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "UserWithId", substitutionVariables: ["ID": id])
        
        if let result = try? mainContext.fetch(userRequest!) as? [CDUser],
            let user = result?.first {
            interlocutor = User(id: id, name: user.name)
        }
        
        let messagesRequest = (saveContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "MessagesInConversationWithId", substitutionVariables: ["ID": id])) as! NSFetchRequest<CDMessage>
        
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        messagesRequest.sortDescriptors = [dateSortDescriptor]
        
        fetchedResultController = NSFetchedResultsController<CDMessage>(fetchRequest: messagesRequest,
                                                                             managedObjectContext: mainContext,
                                                                             sectionNameKeyPath: nil,
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
    
    init?(withManager manager: ConversationsManager?, status: Bool, andNotRead readStatus: Bool) {
        self.manager = manager
        guard let newChat = ConversationProvider.getNewConversation(online: status, andNotRead: readStatus) else {
            return nil
        }
        super.init()
        let user = User(id: newChat.name, name: newChat.name)
//        self.interlocutor = user
//        self.online = newChat.online
//        self.isUnread = readStatus
//
//        if let message = newChat.message {
//            messages = [Message]()
//            messages!.append(Message(text: message, date: newChat.date, sender: interlocutor, isIncoming: true))
//        }
//        lastActivityDate = newChat.date
        setupFRC(withId: user.id)
        fetchData()
    }
    
    func sendMessage(text: String) {
        manager?.sendMessage(string: text, to: interlocutor.id) { [weak self] flag, error in
            if let strongSelf = self {
                // To do - Finish offline send develpment
                if (flag || !(strongSelf.online)) {
                    let date = Date()

                    let messageRequest = NSFetchRequest<CDMessage>(entityName: "CDMessage")
                    let messageId = try? strongSelf.saveContext.fetch(messageRequest).count + 1
                    let message = NSEntityDescription.insertNewObject(forEntityName: "CDMessage", into: strongSelf.saveContext) as! CDMessage
                    message.text = text
                    message.id = String(messageId ?? 0)
                    message.date = date
                    message.incoming = false
    
                    let conversationRequest =  strongSelf.saveContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "ConversationWithUser", substitutionVariables: ["ID": strongSelf.interlocutor.id])
                    
                    if let results = try? strongSelf.saveContext.fetch(conversationRequest!) as? [CDConversation],
                        let foundConversation = results?.first {
                        foundConversation.text = text
                        foundConversation.date = date
                        message.conversation = foundConversation
                    } else {
                        print("не вытащили юзера")
                    }
                    AppDelegate.storeManager.save(completionHandler: {flag in print("ОТПРАВШИ СОХРАНИЛ")})
//                    message.conversation = conversation
//                    conversation.text = text
//                    conversation.date = date
                    
//                    let newMessage = Message(text: text, date: Date(), sender: User.me, isIncoming: false)
//                    strongSelf.lastActivityDate = newMessage.date
//                    if strongSelf.messages == nil {strongSelf.messages = [Message]()}
//                    strongSelf.messages!.append(newMessage)
//                    //strongSelf.manager?.sortDialogs()
//                    strongSelf.tableView?.reloadData()
//                    //strongSelf.manager?.reloadSections(strongSelf.online ? [0]:[1])
//                    //strongSelf.manager?.tableView?.reloadSections(strongSelf.online ? [0]:[1], with: .right)
                }
            }
        }
    }
}

extension Conversation: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sectionsCount = fetchedResultController?.sections?.count else {
            print("Не понял, сколько секций conversation")
            return 1
        }
        return sectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = fetchedResultController?.sections else {
            print("Не понял, сколько элементов в секциях")
            return 0
        }
        let value = sections[section].numberOfObjects
        return value
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath) as? MessageCell
        let cell = dequeuedCell ?? MessageCell()
        if let storedMessage = fetchedResultController?.object(at: indexPath) {
            cell.isIncoming = storedMessage.incoming
            cell.message = storedMessage.text
        }
        return cell
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//
//        return messages == nil ? ConversationListCell.noMessagesConst : nil
//    }

}

extension Conversation : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView?.deleteRows(at: [indexPath], with: .automatic)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView?.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                tableView?.deleteRows(at: [indexPath], with: .automatic)
            }
            
            if let newIndexPath = newIndexPath {
                tableView?.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                tableView?.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
}
