//
//  ConversationsListTableViewCell.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 10.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell, ConversationCellConfiguration{

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    private let noMessagesConst = "No messages yet"
    
    var name: String? {
        didSet {
            nameLabel.text = name
        }
    }
    
    var message: String? {
        didSet {
            messageLabel.text = message ?? noMessagesConst
            
            let fontSize = messageLabel.font.pointSize
            var traits = messageLabel.font.fontDescriptor.symbolicTraits
            switch message {
            case nil:
                traits.insert(.traitItalic)
            default:
                traits.remove(.traitItalic)
            }
            messageLabel.font = UIFont(descriptor: messageLabel.font.fontDescriptor.withSymbolicTraits(traits)!, size: fontSize)
        }
    }
    
    var date: Date? {
        didSet {
            if let unwrappedDate = date {
                let today = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ru_RU")
                formatter.dateFormat = unwrappedDate < today ? "dd MMM" : "HH:mm"
                dateLabel.text = formatter.string(from: unwrappedDate)
            }
        }
    }
    
    var online: Bool = true {
        didSet {
            self.backgroundColor = online ? #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }

    var hasUnreadMessages: Bool = false {
        didSet {
            let fontSize = messageLabel.font.pointSize
            var traits = messageLabel.font.fontDescriptor.symbolicTraits
            switch hasUnreadMessages {
            case true:
                traits.insert(.traitBold)
            default:
                traits.remove(.traitBold)
            }
             messageLabel.font = UIFont(descriptor: messageLabel.font.fontDescriptor.withSymbolicTraits(traits)!, size: fontSize)
        }
    }
}
