//
//  ConversationsListTableViewCell.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 10.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

class ConversationListCell: UITableViewCell, ConversationCellConfiguration{

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    static let noMessagesConst = "Сообщений пока нет"
    
    var name: String? {
        didSet {
            nameLabel.text = name
        }
    }
    
    var message: String? {
        set {
            messageLabel.text = newValue ?? ConversationListCell.noMessagesConst
            
            let fontSize = messageLabel.font.pointSize
            var traits = messageLabel.font.fontDescriptor.symbolicTraits
            switch newValue {
            case nil:
                traits.insert(.traitItalic)
            default:
                traits.remove(.traitItalic)
            }
            messageLabel.font = UIFont(descriptor: messageLabel.font.fontDescriptor.withSymbolicTraits(traits)!, size: fontSize)
        }
        get {
            return messageLabel.text == ConversationListCell.noMessagesConst ? nil: messageLabel.text
        }
    }
    
    var date: Date? {
        didSet {
            if let unwrappedDate = date {
                let today = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ru_RU")
                
                if unwrappedDate < today {
                    formatter.dateFormat = "dd MMM"
                    let dateString = formatter.string(from: unwrappedDate)
                    let index = dateString.index(dateString.startIndex, offsetBy: 6)
                    dateLabel.text = String(dateString[..<index])
                } else {
                    formatter.dateFormat = "HH:mm"
                    dateLabel.text = formatter.string(from: unwrappedDate)
                }
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
