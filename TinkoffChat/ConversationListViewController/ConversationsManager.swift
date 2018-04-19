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
    
//    private var conversations: [Conversation]!
    private weak var tableView: UITableView?
    var communicator: MultipeerCommunicator!
    
//    var onlineConversations: [Conversation]? {
//        guard let conv = conversations else {
//            return nil
//        }
//        let filteredConv = conv.filter {$0.online}
//        return filteredConv.count > 0 ? filteredConv : nil
//    }
//
//    var offlineConversations: [Conversation]? {
//        guard let conv = conversations else {
//            return nil
//        }
//        let filteredConv = conv.filter {!$0.online}
//        return filteredConv.count > 0 ? filteredConv : nil
//    }

    init(with tableView: UITableView) {
        super.init()
        self.tableView = tableView
        self.setCommunicator()
        self.setConversations()
        setupFRC()
        fetchData()
    }
    
    
    // MARK: - Private
    
    private func setupFRC() {
        mainContext = AppDelegate.storeManager.mainContext
        saveContext = AppDelegate.storeManager.saveContext
        //self.context?.persistentStoreCoordinator?.managedObjectModel.fetchRequestTemplate(forName: "ConversationsOnline")
        let fetchRequest = NSFetchRequest<CDConversation>(entityName: "CDConversation")
        let idSortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        let onlineSortDescriptor = NSSortDescriptor(key: "online", ascending: false)
        fetchRequest.sortDescriptors = [onlineSortDescriptor, idSortDescriptor]

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
    
    private func setConversations() {
        //conversations = [Conversation]()
        getTestConversations()
        //sortDialogs()
    }
    
    private func getTestConversations() {
        let boolArray = [false,false,false]
        outerloop: for status in boolArray {
            for readStatus in boolArray.reversed() {
                if (!addConversation(online: status, hasUnreadMessages: readStatus)){
                    break outerloop
                }
            }
        }
    }
    
    private func addConversation(online: Bool, hasUnreadMessages: Bool) -> Bool {
        guard let newChat = ConversationProvider.getNewConversation(online: online, andNotRead: hasUnreadMessages) else {
            return false
        }
        let context = AppDelegate.storeManager.saveContext
        
        let conversationRequest = NSFetchRequest<CDConversation>(entityName: "CDConversation")
        let conversationId = try? context.fetch(conversationRequest).count + 1
        let conversation = NSEntityDescription.insertNewObject(forEntityName: "CDConversation", into: context) as! CDConversation
        conversation.id = Int64(conversationId ?? 0)
        conversation.online = newChat.online
        conversation.hasUnreadMessages = hasUnreadMessages
        conversation.date = newChat.date
        
        if let text = newChat.message {
            let messageRequest = NSFetchRequest<CDMessage>(entityName: "CDMessage")
            let messageId = try? context.fetch(messageRequest).count + 1
            let message = NSEntityDescription.insertNewObject(forEntityName: "CDMessage", into: context) as! CDMessage
            message.text = text
            message.id = String(messageId ?? 0)
            message.date = newChat.date
            message.incoming = online
            conversation.text = text
            message.conversation = conversation
        }
        
        let userRequest = NSFetchRequest<CDUser>(entityName: "CDUser")
        let userId = try? context.fetch(userRequest).count + 1
        let user = NSEntityDescription.insertNewObject(forEntityName: "CDUser", into: context) as! CDUser
        user.id =  String(userId ?? 0)
        user.name = newChat.name
        conversation.interlocutor = user
        
        
//        self.interlocutor = User(id: newChat.name, name: newChat.name)
//        self.online = newChat.online
//        self.isUnread = readStatus
//
//        if let message = newChat.message {
//            messages = [Message]()
//            messages!.append(Message(text: message, date: newChat.date, sender: interlocutor, isIncoming: true))
//        }
//        lastActivityDate = newChat.date
        AppDelegate.storeManager.save(completionHandler: {flag in if (flag) {print("СОХРАНИЛ БОТОСООБЩЕНИЯ")}})
        return true
    }
    
//    func sortDialogs() {
//        conversations!.sort { first, second in
//            if let firstDate = first.lastActivityDate,
//                let secondDate = second.lastActivityDate {
//                return firstDate > secondDate
//            }
//            if let firstName = first.interlocutor.name,
//                let secondName = second.interlocutor.name {
//                return firstName > secondName
//            }
//            return first.interlocutor.id > second.interlocutor.id
//        }
//    }
    
    func reloadSections(_ indexSet: IndexSet) {
        tableView?.reloadSections(indexSet, with: .right)
    }
    
    func getIdForIndexPath(_ indexPath: IndexPath) -> String {
        if let value = fetchedResultController?.object(at: indexPath).interlocutor?.id {
            return value
        }
        print("не нашел значение")
        return ""
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
//        let conversationLength = section == 0 ? onlineConversations?.count : offlineConversations?.count
//        return conversationLength ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ConversationListCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "conversationIdentifier", for: indexPath) as? ConversationListCell {
            cell = dequeuedCell
        } else {
            cell = ConversationListCell()
        }
        //let conversation = indexPath.section == 0 ?  onlineConversations![indexPath.row] : offlineConversations![indexPath.row]
        
        if let conversation = fetchedResultController?.object(at: indexPath) {
            cell.name = conversation.interlocutor?.name ?? conversation.interlocutor?.id ?? "имечко"
            cell.hasUnreadMessages = conversation.hasUnreadMessages
            cell.online = conversation.online
            cell.message = conversation.text
            cell.date = conversation.date
//            var lastMessage = conversation.messages?.allObjects.sorted(by: { first, second in
//                guard let one = first as? CDMessage,
//                let another = second as? CDMessage,
//                    let firstDate = one.date,
//                    let secondDate = another.date else {
//                        print("что-то не досталось")
//                        return false
//                }
//
//                return firstDate > secondDate
//            }).last as? CDMessage // conversation.messages?.allObjects.last as? CDMessage
//            cell.message = lastMessage?.text
//            cell.date = lastMessage?.date
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? SectionsNames.Online.rawValue : SectionsNames.Offline.rawValue
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension ConversationsManager : NSFetchedResultsControllerDelegate {
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

// MARK: - CommunicatorDelegate
extension ConversationsManager : CommunicatorDelegate {
    
    func didFoundUser(userID: String, userName: String?) {
        let date = Date()
        let mainContext = AppDelegate.storeManager.mainContext
        let saveContext = AppDelegate.storeManager.saveContext
        let userRequest =  saveContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "UserWithId", substitutionVariables: ["ID": userID])
        if let user = ((try? mainContext.fetch(userRequest!)) as? [CDUser])?.first {
            let conversationRequest =  saveContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "ConversationWithUser", substitutionVariables: ["ID": (user.id)!])
            
            if let results = (try? saveContext.fetch(conversationRequest!)) as? [CDConversation],
                let foundConversation = results.first {
                foundConversation.text = ConversationListCell.noMessagesConst
                foundConversation.date = date
            } else {
                print("не вытащили юзера")
            }
        } else {
            let user = NSEntityDescription.insertNewObject(forEntityName: "CDUser", into: saveContext) as! CDUser
            user.id =  userID
            user.name = userName ?? userID
            
            let conversationRequest = NSFetchRequest<CDConversation>(entityName: "CDConversation")
            let conversationId = try? saveContext.fetch(conversationRequest).count + 1
            let conversation = NSEntityDescription.insertNewObject(forEntityName: "CDConversation", into: saveContext) as! CDConversation
            conversation.id = Int64(conversationId ?? 0)
            conversation.online = true
            conversation.hasUnreadMessages = true
            conversation.date = date
            conversation.interlocutor = user
            
            //conversation.interlocutor = user
        }
        AppDelegate.storeManager.save(completionHandler: {flag in print("Принял Юзера")})
//        let user = NSEntityDescription.insertNewObject(forEntityName: "CDUser", into: context) as! CDUser
//        user.id =  String(userId ?? 0)
//        user.name = newChat.name
//        conversation.interlocutor = user
        
//        let user = User(id: userID, name: userName)
//        if let index = conversations.indexFor(user: user) {
//            if (conversations[index].online == true) {return}
//            conversations[index].online = true
//            DispatchQueue.main.async { [weak self] in
//                self?.tableView?.reloadData()
//            }
//        } else {
//
//            let newUser = User(id: userID, name: userName)
//            let newConversation = Conversation(withManager: self, interlocutor: newUser, andStatus: true)
//            conversations.append(newConversation)
//
//            DispatchQueue.main.async { [weak self] in
//                self?.tableView?.reloadSections([0], with: .automatic)
//            }
//        }
    }
    
    func didLostUser(userID: String) {
        let saveContext = AppDelegate.storeManager.saveContext
        let userRequest =  saveContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "UserWithId", substitutionVariables: ["ID": userID])
        if let user = ((try? saveContext.fetch(userRequest!)) as? [CDUser])?.first {
            let conversationRequest =  saveContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "ConversationWithUser", substitutionVariables: ["ID": (user.id)!])
            
            if let results = (try? saveContext.fetch(conversationRequest!)) as? [CDConversation],
                let foundConversation = results.first {
                foundConversation.online = false
            } else {
                print("не вытащили юзера")
            }
        }
        AppDelegate.storeManager.save(completionHandler: {flag in print("Удалил Юзера")})
//        let user = User(id: userID, name: nil)
//        if let index = conversations.indexFor(user: user) {
//            if (conversations[index].online == false) {return}
//            conversations[index].online = false
//            DispatchQueue.main.async { [weak self] in
//                self?.tableView?.reloadData()
//            }
//        }

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
        let saveContext = AppDelegate.storeManager.saveContext
        let userRequest =  saveContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "UserWithId", substitutionVariables: ["ID": fromUserWithId])
        if let user = ((try? mainContext.fetch(userRequest!)) as? [CDUser])?.first {
            let conversationRequest =  saveContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "ConversationWithUser", substitutionVariables: ["ID": (user.id)!])
            
            if let results = (try? saveContext.fetch(conversationRequest!)) as? [CDConversation],
                let foundConversation = results.first {
                let messageRequest = NSFetchRequest<CDMessage>(entityName: "CDMessage")
                let messageId = try? saveContext.fetch(messageRequest).count + 1
                let message = NSEntityDescription.insertNewObject(forEntityName: "CDMessage", into: saveContext) as! CDMessage
                message.text = text
                message.id = String(messageId ?? 0)
                message.date = date
                message.incoming = true
                foundConversation.text = text
                foundConversation.date = date
                message.conversation = foundConversation
            } else {
                print("не вытащили беседу")
            }
        }
//        let user = User(id: fromUser, name: fromUser)
//        guard let index = conversations.indexFor(user: user) else {
//            print("didReceiveMessage NOT ONLINE?")
//            return
//        }
//
//        if  conversations[index].messages == nil {
//            conversations[index].messages = [Message]()
//        }
//        let currentConversation = conversations[index]
//        let newMessage = Message(text: text, date: Date(), sender: currentConversation.interlocutor, isIncoming: true)
//        currentConversation.messages!.append(newMessage)
//
//        DispatchQueue.main.async { [weak self] in
//            self?.tableView?.reloadData()
//            currentConversation.tableView?.reloadData()
//        }
//    }
    }
}

//extension Array where Element: Conversation {
//    func indexFor(user: User) -> Int? {
//        var resultIndex: Int? = nil
//        for (index, element) in self.enumerated() {
//            if element.interlocutor.id == user.id {
//                resultIndex = index
//                if let newName = user.name {
//                    element.interlocutor.name = newName
//                }
//            }
//        }
//        return resultIndex
//    }
//}
