//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 12.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

class ConversationViewController: UITableViewController {
    
//    private let botMessage = "Я на выборы никогда не ходил, но в этот раз точно пойду за Грудинина голосовать. Кандидат от народа!"
    
//    var messages = [
//        ("Привет!", true),
//        ("Пока!", false)
//    ]
    
    var conversation: Conversation!
    
    //var interlocutor: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = conversation.interlocutor // interlocutor
        
        
        // t delete
//        if messages.count != 0 {
//            let lastViewed = messages.popLast()!
//            messages.append((botMessage + "\n" + botMessage + "\n" + botMessage, true))
//            messages.append(("Я", false))
//            messages.append((botMessage, true))
//            messages.append((botMessage, false))
//            messages.append(("Я", true))
//            messages.append((botMessage + "\n" + botMessage + "\n" + botMessage, false))
//            messages.append(lastViewed)
//        }
        // t delete
        
        //to udgrade
        //conversation.messages.isEmpty
        
        if let messages = conversation.messages { //if messages.count != 0 {
            var avgHeight = CGFloat(0)
            let windowWidth = UIScreen.main.bounds.width
            let constraintRect = CGSize(width: windowWidth, height: .greatestFiniteMagnitude)
            
            for message in messages {
                let boundingBox = message.text!.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)], context: nil)
                avgHeight += boundingBox.height
            }
            avgHeight = avgHeight / CGFloat(messages.count)//messages.count)
            
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = avgHeight
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.messages?.count ?? 0 //messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath) as? MessageCell
        let cell = dequeuedCell ?? MessageCell()
        
        let message = conversation.messages![indexPath.row] //messages[indexPath.row]
        cell.isIncoming = message.isIncoming
        cell.message = message.text
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return conversation.messages == nil ? ConversationListCell.noMessagesConst : nil
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let windowWidth = UIScreen.main.bounds.width
//        let constraintRect = CGSize(width: windowWidth, height: .greatestFiniteMagnitude)
//        let boundingBox = messages[indexPath.row].0.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)], context: nil)
//        return boundingBox.height + 30
//    }

}
