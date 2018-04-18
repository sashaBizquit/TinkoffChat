//
//  Conversation.swift
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
    var interlocutor: User!
    var online: Bool = true
    var isUnread: Bool = true
    var messages: [Message]?
    var lastMessage: Message? {
        return messages?.last
    }
    var lastActivityDate: Date!
    
    weak var tableView: UITableView?
    var dialogs: Conversations?
    
    init(withInterlocutor user: User, andStatus status: Bool) {
        super.init()
        interlocutor = user
        online = status
    }
    
    init?(withStatus status: Bool, andNotRead readStatus: Bool) {
        guard let newChat = ConversationCellModel.getNewConversation(online: status, andNotRead: readStatus) else {
            return nil
        }
        super.init()
        interlocutor = User(id: newChat.name, name: newChat.name)
        online = newChat.online
        isUnread = readStatus
        
        if let message = newChat.message {
            messages = [Message]()
            messages!.append(Message(text: message, date: newChat.date, sender: interlocutor, isIncoming: true))
        }
        lastActivityDate = newChat.date
    }
    
    func sendMessage(text: String) {
        dialogs?.communicator.sendMessage(string: text, to: interlocutor.id) { [weak self] flag, error in
            if let strongSelf = self {
                // To do - Finish offline send develpment
                if (flag || !(strongSelf.online)) {
                    let newMessage = Message(text: text, date: Date(), sender: User.me, isIncoming: false)
                    strongSelf.lastActivityDate = newMessage.date
                    if strongSelf.messages == nil {strongSelf.messages = [Message]()}
                    strongSelf.messages!.append(newMessage)
                    strongSelf.dialogs?.sortDialogs()
                    strongSelf.tableView?.reloadData()
                    strongSelf.dialogs?.tableView?.reloadSections(strongSelf.online ? [0]:[1], with: .right)
                }
            }
        }
    }
}

extension Conversation: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages?.count ?? 0
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
