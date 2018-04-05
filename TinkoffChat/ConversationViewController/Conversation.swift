//
//  Conversations.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 04.04.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import Foundation

struct Message {
    var text: String?
    var date: Date?
    var sender: User
    var isIncoming: Bool
}

struct User {
    var userId: String
    var userName: String?
    
    static var me: User {
        return User(userId: MultipeerCommunicator.myPeerId.displayName, userName: "Александр Лыков")
    }
}

class Conversation: NSObject, UITableViewDataSource {
    var interlocutor: User!
    var online: Bool = true
    var isUnread: Bool = true
    var messages: [Message]?
    var lastMessage: Message? {
        return messages?.last
    }
    
    weak var tableViewController: UITableViewController?
    weak var communicator: MultipeerCommunicator?
    
    init(withInterlocutor user: User, andStatus status: Bool) {
        super.init()
        interlocutor = user
        online = status
    }
    
    func sendMessage(text: String) {
        communicator?.sendMessage(string: text, to: interlocutor.userId) { flag, error in
            
        }
    }
    
    init?(withStatus status: Bool, andNotRead readStatus: Bool) {
        super.init()
        guard let newChat = ConversationCellModel.getNewConversation(online: status, andNotRead: readStatus) else {
            return nil
        }
        
        interlocutor = User(userId: newChat.name, userName: newChat.name)
        online = newChat.online
        isUnread = readStatus
        
        if let message = newChat.message {
            messages = [Message]()
            messages!.append(Message(text: message, date: newChat.date, sender: interlocutor, isIncoming: true))
            botInsert()
        }
    }

    private let botMessage = "Я на выборы никогда не ходил, но в этот раз точно пойду за Грудинина голосовать. Кандидат от народа!"
    private func botInsert() {
        let lastViewed = messages!.popLast()!
        messages!.append(Message(text: botMessage + "\n" + botMessage + "\n" + botMessage, date: Date(), sender: interlocutor, isIncoming: true))
        messages!.append(Message(text: "Я", date: Date(), sender: interlocutor, isIncoming: false))
        messages!.append(Message(text: botMessage, date: Date(), sender: interlocutor, isIncoming: true))
        messages!.append(Message(text: botMessage, date: Date(), sender: interlocutor, isIncoming: false))
        messages!.append(Message(text: "Я", date: Date(), sender: interlocutor, isIncoming: true))
        messages!.append(Message(text: botMessage + "\n" + botMessage + "\n" + botMessage, date: Date(), sender: interlocutor, isIncoming: false))
        messages!.append(lastViewed)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages?.count ?? 0 //messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath) as? MessageCell
        let cell = dequeuedCell ?? MessageCell()
        
        let message = messages![indexPath.row]
        cell.isIncoming = message.isIncoming
        cell.message = message.text
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return messages == nil ? ConversationListCell.noMessagesConst : nil
    }

}
