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
        self.init(id: newId, name: newName, photoURL: nil, info: nil)
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
    private var storeManager: StoreManager!
    private weak var parentManager: ConversationsManager?
    
    var interlocutor: User!
    var online: Bool {
        let conversationRequest =  storeManager.mainContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "ConversationWithUser", substitutionVariables: ["ID": interlocutor.id])
        if let results = try? storeManager.mainContext.fetch((conversationRequest!)) as? [CDConversation],
            let foundConversation = results?.first {
            return foundConversation.online
        }
        return false
    }
    
    weak var tableView: UITableView?
    
    init(withConversationsManager cManager: ConversationsManager?, storeManager sManager: StoreManager, userId id: Int64) {
        super.init()
        self.storeManager = sManager
        self.parentManager = cManager
        self.setupFRC(withId: id)
        self.fetchData()
    }
    
    
    // MARK: - Private
    
    private func setupFRC(withId conversationId: Int64) {
        let conversationRequest = storeManager.mainContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "ConversationWithId", substitutionVariables: ["ID": conversationId])
        
        if let result = try? storeManager.mainContext.fetch(conversationRequest!) as? [CDConversation],
            let conversation = result?.first {
            if let userId = conversation.interlocutor?.id {
                interlocutor = User(id: userId, name: conversation.interlocutor?.name)
            } else {
                print("Conversation \(conversationId) with no-id-user")
            }
        } else {
            print("No conversation with id == \(conversationId)")
        }
        
        let messagesRequest = (storeManager.mainContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "MessagesInConversationWithId", substitutionVariables: ["ID": conversationId])) as! NSFetchRequest<CDMessage>
        
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        messagesRequest.sortDescriptors = [dateSortDescriptor]
        
        fetchedResultController = NSFetchedResultsController<CDMessage>(fetchRequest: messagesRequest,
                                                                             managedObjectContext: storeManager.mainContext,
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
    
    func sendMessage(text: String) {
        parentManager?.sendMessage(string: text, to: interlocutor.id) { [weak self] flag, error in
            guard let strongSelf = self else {
                print("Нет беседы")
                return
            }
            if (!flag && strongSelf.online) {
                return
            }
            // To do - Finish offline send develpment
            let date = Date()
            let context = strongSelf.storeManager.saveContext
            let cRequest =  context.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplate(withName: "ConversationWithUser", substitutionVariables: ["ID": strongSelf.interlocutor.id])
            let storeManager = strongSelf.storeManager
            context.performAndWait { [weak storeManager] in
                guard let strongManager = storeManager else {
                    print("Нет беседы")
                    return
                }
                guard let results = try? strongManager.saveContext.fetch(cRequest!) as? [CDConversation],
                    let foundConversation = results?.first else {
                        print("не вытащили юзера")
                        return
                }
                foundConversation.text = text
                foundConversation.date = date
                strongManager.putNewMessage(withText: text, date: date, hasSendToMe: false, conversation: foundConversation) { [weak strongManager] _ in
                    strongManager?.save{ flag in
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
}

extension Conversation: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sectionsCount = fetchedResultController?.sections?.count else {
            print("Не понял, сколько секций conversation")
            return 0
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
        
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath) as? MessageCell
        let cell = dequeuedCell ?? MessageCell()
        if let storedMessage = fetchedResultController?.object(at: indexPath) {
            cell.isIncoming = storedMessage.incoming
            cell.message = storedMessage.text
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (fetchedResultController?.fetchedObjects?.count ?? 0) == 0 ? ConversationListCell.noMessagesConst : nil
    }

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
