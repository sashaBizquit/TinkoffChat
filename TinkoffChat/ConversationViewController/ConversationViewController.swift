//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 12.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

class ConversationViewController: UITableViewController, UITextViewDelegate{
    
    var conversation: Conversation!
    
    @IBOutlet weak var messageTextView: UITextView!
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        self.messageTextView.delegate = self;
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        messageTextView.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text = textView.text  {
            if text.count == 0 {return}
            if conversation.online {
                conversation.sendMessage(text: text)
            }
            textView.text = "Нажмите, чтобы написать сообщение"
        }
    }
}
