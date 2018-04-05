//
//  ConversationsModel.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 04.04.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import Foundation

enum SectionsNames: String {
    case Online = "Онлайн", Offline = "Офлайн"
}

class Conversations {
    private var conversations: [Conversation]?
    
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
    
    init() {
        conversations = [Conversation]()
        let boolArray = [true,false,true,true]
        outerloop: for status in boolArray {
            for readStatus in boolArray.reversed() {
                if let conversation = Conversation(withStatus: status, andNotRead: readStatus) {
                    conversations?.append(conversation)
                } else {
                    break outerloop
                }
            }
        }
        conversations!.sort { first, second in
            if let firstDate = first.lastMessage?.date,
                let secondDate = second.lastMessage?.date {
                return firstDate > secondDate
            }
            return first.interlocutor > second.interlocutor
        }
    }
}
