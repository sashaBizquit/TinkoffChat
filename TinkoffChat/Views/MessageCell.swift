//
//  ConversationCell.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 13.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var outgoingLabel: UILabel!
    @IBOutlet weak var incomingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
