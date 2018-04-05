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
    var sender: String
    var isIncoming: Bool
}

class Conversation {
    var interlocutor: String!
    var online: Bool = false
    var hasUnreadMessages: Bool = false
    var messages: [Message]?
    var lastMessage: Message? {
        return messages?.last
    }
    
    private let botMessage = "Я на выборы никогда не ходил, но в этот раз точно пойду за Грудинина голосовать. Кандидат от народа!"
    private func botInsert() {
        let lastViewed = messages!.popLast()!
        messages!.append(Message(text: botMessage + "\n" + botMessage + "\n" + botMessage, date: Date(), sender: "", isIncoming: true))
        messages!.append(Message(text: "Я", date: Date(), sender: "", isIncoming: false))
        messages!.append(Message(text: botMessage, date: Date(), sender: "", isIncoming: true))
        messages!.append(Message(text: botMessage, date: Date(), sender: "", isIncoming: false))
        messages!.append(Message(text: "Я", date: Date(), sender: "", isIncoming: true))
        messages!.append(Message(text: botMessage + "\n" + botMessage + "\n" + botMessage, date: Date(), sender: "", isIncoming: false))
        messages!.append(lastViewed)
    }
    
    init?(withStatus status: Bool, andNotRead readStatus: Bool) {
        guard let newChat = ConversationCellModel.getNewConversation(online: status, andNotRead: readStatus) else {
            return nil
        }
        
        if let message = newChat.message {
            
            messages = [Message]()
            messages!.append(Message(text: message, date: newChat.date, sender: newChat.name, isIncoming: true))
            botInsert()
        }
        
        interlocutor = newChat.name
        online = newChat.online
        hasUnreadMessages = readStatus
    }
    
    init(withInterlocutor name: String, withStatus status: Bool) {
        interlocutor = name
        online = status
    }
}
