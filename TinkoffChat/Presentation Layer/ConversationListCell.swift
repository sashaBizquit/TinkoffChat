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
    
    var name: String {
        get {
            guard let labelName = nameLabel.text else {
                assert(false, "ConversationListCell: nameLabel contains no text")
            }
            return labelName
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    var message: String? {
        set {
            messageLabel.text = newValue ?? ConversationListCell.noMessagesConst
            self.toggleFont(with: .traitItalic, andFlag: newValue == nil)
        }
        get {
            return messageLabel.text == ConversationListCell.noMessagesConst ? nil: messageLabel.text
        }
    }
    
    var date: Date? {
        didSet {
            if let unwrappedDate = date {
                let today = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) ?? Date()
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
    
    var online: Bool {
        set {
            backgroundColor = newValue ? #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        get {
            return backgroundColor == #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        }
    }

    var hasUnreadMessages: Bool = false {
        didSet {
            self.toggleFont(with: .traitBold, andFlag: hasUnreadMessages)
        }
    }
    private func toggleFont(with trait: UIFontDescriptorSymbolicTraits, andFlag flag: Bool) {
        let fontSize = messageLabel.font.pointSize
        var traits = messageLabel.font.fontDescriptor.symbolicTraits
        if (flag) {
            traits.insert(trait)
        } else {
            traits.remove(trait)
        }

        guard let fontDescriptor = messageLabel.font.fontDescriptor.withSymbolicTraits(traits) else {
            assert(false, "Cant get symbolicTraits from \(messageLabel.font)")
        }
        messageLabel.font = UIFont(descriptor: fontDescriptor, size: fontSize)
    }
}
