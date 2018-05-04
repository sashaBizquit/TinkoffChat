//
//  ConversationCell.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 13.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    private var storedRight: NSLayoutConstraint?
    private var storedLeft: NSLayoutConstraint?
    
    var message: String? {
        didSet {
            label.text = message
        }
    }
    var isIncoming = true {
        didSet {
            messageView.backgroundColor = isIncoming ? #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) : #colorLiteral(red: 0.5563425422, green: 0.9793455005, blue: 0, alpha: 1)
            
            if rightConstraint == nil {
                rightConstraint = storedRight
            } else {
                storedRight = rightConstraint
            }
            if leftConstraint == nil {
                leftConstraint = storedLeft
            } else {
                storedLeft = leftConstraint
            }
            
            rightConstraint.isActive = !isIncoming
            leftConstraint.isActive = isIncoming
            label.preferredMaxLayoutWidth = contentView.frame.width * 0.75 - (isIncoming ? leftConstraint : rightConstraint).constant
        }
    }

}
