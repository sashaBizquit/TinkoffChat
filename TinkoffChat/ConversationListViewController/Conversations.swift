//
//  ConversationsModel.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 04.04.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum SectionsNames: String {
    case Online = "Онлайн", Offline = "Офлайн"
}

class Conversations: NSObject {
    private var conversations: [Conversation]!
    weak var tableViewController: UITableViewController?
    weak var communicator: MultipeerCommunicator!
    
    var onlineConversations: [Conversation]? {
        guard let conv = conversations else {
            return nil
        }
        let filteredConv = conv.filter {$0.online}
        return filteredConv.count > 0 ? filteredConv : nil
    }
    
    var offlineConversations: [Conversation]? {
        guard let conv = conversations else {
            return nil
        }
        let filteredConv = conv.filter {!$0.online}
        return filteredConv.count > 0 ? filteredConv : nil
    }
    
    private func getTestConversations() {
        let boolArray = [false,false,false]
        outerloop: for status in boolArray {
            for readStatus in boolArray.reversed() {
                if let conversation = Conversation(withStatus: status, andNotRead: !readStatus) {
                    conversation.communicator = communicator
                    conversations?.append(conversation)
                } else {
                    break outerloop
                }
            }
        }
    }
    
    override init() {
        super.init()
//        communicator = MultipeerCommunicator()
//        communicator.delegate = self

        conversations = [Conversation]()
        
        getTestConversations()
        
        conversations!.sort { first, second in
            if let firstDate = first.lastMessage?.date,
                let secondDate = second.lastMessage?.date {
                return firstDate > secondDate
            }
            if let firstName = first.interlocutor.userName,
                let secondName = second.interlocutor.userName {
                return firstName > secondName
            }
            return first.interlocutor.userId > second.interlocutor.userId
        }
    }
}

// MARK: - Table view data source
extension Conversations : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let conversation = section == 0 ? onlineConversations?.count : offlineConversations?.count
        return conversation ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: ConversationListCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "conversationIdentifier", for: indexPath) as? ConversationListCell {
            cell = dequeuedCell
        } else {
            cell = ConversationListCell()
        }
        let conversation = indexPath.section == 0 ?  onlineConversations![indexPath.row] : offlineConversations![indexPath.row]
        
        cell.name = conversation.interlocutor.userName ?? conversation.interlocutor.userId
        cell.message = conversation.messages == nil ? ConversationListCell.noMessagesConst : conversation.lastMessage!.text
        cell.date = conversation.lastMessage?.date
        cell.hasUnreadMessages = conversation.isUnread
        cell.online = conversation.online
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? SectionsNames.Online.rawValue : SectionsNames.Offline.rawValue
    }
}

// MARK: - CommunicatorDelegate
extension Conversations : CommunicatorDelegate {
    
    func didFoundUser(userID: String, userName: String?) {
        let user = User(userId: userID, userName: userName)
        if let index = conversations.indexFor(user: user) {
            if (conversations[index].online ==  true) {return}
            conversations[index].online = true
        } else {
            let newUser = User(userId: userID, userName: userName)
            let newConversation = Conversation(withInterlocutor: newUser, andStatus: true)
            newConversation.communicator = communicator
            conversations.append(newConversation)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.tableViewController?.tableView.reloadSections([0], with: .right)
        }
    }
    
    func didLostUser(userID: String) {
        let user = User(userId: userID, userName: nil)
        if let index = conversations.indexFor(user: user) {
            if (conversations[index].online ==  false) {return}
            conversations[index].online = false
            DispatchQueue.main.async { [weak self] in
                self?.tableViewController?.tableView.reloadSections([0], with: .left)
            }
        }

    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        print("failedToStartBrowsingForUsers: \(error.localizedDescription)")
    }
    
    func failedToStartAdvertising(error: Error) {
        print("failedToStartAdvertising: \(error.localizedDescription)")
    }
    
    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        let user = User(userId: fromUser, userName: fromUser)
        guard let index = onlineConversations!.indexFor(user: user) else {
            print("didReceiveMessage NOT ONLINE")
            return
        }
        let currentConversation = conversations[index]
        if  currentConversation.messages == nil {
            conversations[index].messages = [Message]()
        }
        let newMessage = Message(text: text, date: Date(), sender: currentConversation.interlocutor, isIncoming: true)
        currentConversation.messages!.append(newMessage)
        
        DispatchQueue.main.async { [weak self] in
            self?.tableViewController?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            //self?.tableViewController?.tableView.reloadSections([0], with: .left)
        
            currentConversation.tableViewController?.tableView.reloadData()
        }
    }
}

extension Array where Element: Conversation {
    func indexFor(user: User) -> Int? {
        var resultIndex: Int? = nil
        for (index, element) in self.enumerated() {
            if element.interlocutor.userId == user.userId {
                resultIndex = index
                if let newName = user.userName {
                    element.interlocutor.userName = newName
                }
            }
        }
        return resultIndex
    }
}
