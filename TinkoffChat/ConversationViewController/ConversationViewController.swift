//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 12.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

class ConversationViewController: UITableViewController {
    
    var conversation: Conversation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = conversation.interlocutor.userName ?? conversation.interlocutor.userId
        tableView.dataSource = conversation
        conversation.tableViewController = self
        
        if let messages = conversation.messages {
            var avgHeight = CGFloat(0)
            let windowWidth = UIScreen.main.bounds.width
            let constraintRect = CGSize(width: windowWidth, height: .greatestFiniteMagnitude)
            
            for message in messages {
                let boundingBox = message.text!.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)], context: nil)
                avgHeight += boundingBox.height
            }
            avgHeight = avgHeight / CGFloat(messages.count)
            
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = avgHeight
        }
    }
}
