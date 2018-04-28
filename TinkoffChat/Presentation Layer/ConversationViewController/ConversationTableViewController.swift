//
//  ConversationTableViewController.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 12.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

class ConversationTableViewController: UITableViewController, UITextViewDelegate{
    
    var conversation: Conversation!
    
    @IBOutlet weak var messageTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let user = conversation.interlocutor
        self.title = user.name ?? user.id
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = conversation
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func setupConversation() {
        conversation.tableView = self.tableView
    }
    
    private func setupTextView() {
        messageTextView.delegate = self
        messageTextView.layer.masksToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.messageTextView.layer.cornerRadius = self.messageTextView.layer.frame.height / 2.0
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
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
