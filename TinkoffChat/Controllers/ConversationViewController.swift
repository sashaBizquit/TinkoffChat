//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 12.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

typealias Message = (String, Bool)

class ConversationViewController: UITableViewController {
    
    private let botMessage = "Я на выборы никогда не ходил, но в этот раз точно пойду за Грудинина голосовать. Кандидат от народа!"
    
    var messages = [
        ("Привет!", true),
        ("Пока!", false)
    ]
    
    var interlocutor: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = interlocutor
        
        if messages.count != 0 {
            let lastViewed = messages.popLast()!
            messages.append((botMessage + "\n" + botMessage + "\n" + botMessage, true))
            messages.append(("Я", false))
            messages.append((botMessage, true))
            messages.append((botMessage, false))
            messages.append(("Я", true))
            messages.append((botMessage + "\n" + botMessage + "\n" + botMessage, false))
            messages.append(lastViewed)
        }
        
        //to udgrade
        if messages.count != 0 {
            var avgHeight = CGFloat(0)
            let windowWidth = UIScreen.main.bounds.width
            let constraintRect = CGSize(width: windowWidth, height: .greatestFiniteMagnitude)
            
            for message in messages {
                let boundingBox = message.0.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)], context: nil)
                avgHeight += boundingBox.height
            }
            avgHeight = avgHeight / CGFloat(messages.count)
            
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = avgHeight
        }
        
//        if messages.count > 0 {
//            self.tableView.scrollToRow(at: IndexPath(row: messages.count-1, section: 0), at: .bottom, animated: true)
//        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: MessageCell
        let message = messages[indexPath.row]
        let isIncoming = message.1
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath) as? MessageCell {
            cell = dequeuedCell
        } else {
            cell = MessageCell()
        }
        cell.isIncoming = isIncoming
        cell.message = message.0
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return messages.count == 0 ? ConversationListCell.noMessagesConst : nil
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let windowWidth = UIScreen.main.bounds.width
//        let constraintRect = CGSize(width: windowWidth, height: .greatestFiniteMagnitude)
//        let boundingBox = messages[indexPath.row].0.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)], context: nil)
//        return boundingBox.height + 30
//    }

}
