//
//  Conversation.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 04.04.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import Foundation
import CoreData

class Conversation: NSObject {
    
    private var fetchedResultController: NSFetchedResultsController<CDMessage>?
    private var storeManager: StoreManagerProtocol
    private weak var parentManager: ConversationsManager?
    weak var tableView: UITableView?
    
    var interlocutor: UserProtocol
    var online: Bool {
        let context = storeManager.mainContext
        let userId = interlocutor.id
        guard let conversation = CDConversation.findConversation(withId: userId, in: context) else {
                assert(false, "Request not found")
                return false
        }
        return conversation.online
    }
    
    init(withConversationsManager cManager: ConversationsManager?, storeManager sManager: StoreManagerProtocol, _ id: Int64) {
        storeManager = sManager
        parentManager = cManager
        guard let user = CDConversation.findConversation(withId: id, in: storeManager.mainContext)?.interlocutor,
            let userId = user.id else {
                assert(false, "No non-nil id user found in conversation == \(id)")
        }
        interlocutor = User(id: userId, name: user.name)
        super.init()
        self.setupFRC(withId: id)
        self.fetchData()
    }
    
    // MARK: - Private
    
    private func setupFRC(withId conversationId: Int64) {
        guard let model = storeManager.mainContext.persistentStoreCoordinator?.managedObjectModel,
            let messagesRequest = CDMessage.fetchRequestMessagesInConversation(withId: conversationId, model: model) else {
            assert(false, "messagesRequest from conversation with id == \(conversationId) not found")
        }
        
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
        let userId = interlocutor.id
        parentManager?.sendMessage(string: text, to: userId) { [weak self] flag, error in
            guard let strongSelf = self else {
                print("Нет беседы")
                return
            }
            if (!flag && strongSelf.online) {
                return
            }
            // To do - Finish offline send develpment
            let date = Date()
            strongSelf.storeManager.saveContext.performAndWait { [weak strongSelf] in
                guard let strongSelf = strongSelf else {
                    print("Нет беседы")
                    return
                }
                let strongManager = strongSelf.storeManager
                guard let foundConversation = CDConversation.findConversation(withId: userId, in: strongSelf.storeManager.saveContext) else {
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
