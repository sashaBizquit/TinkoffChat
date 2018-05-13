//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 28.04.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    private var cornerRadius: CGFloat?
    private var buttonHeight: CGFloat?
    
    private var conversation: Conversation!
    
    init(withConversation conversation: Conversation) {
        super.init(nibName: "ConversationView", bundle: nil)
        self.conversation = conversation
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setDesign()
        setTableView()
        addGestures()
        addObservers()
        setupConversation()
        setupTextView()
    }
    
    private func setDesign() {
        let user = conversation.interlocutor
        self.title = user.name ?? user.id
        sendButton.layer.masksToBounds = true
    }
    
    private func setTableView() {
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "message")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = conversation
    }
    
    private func addGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTextViewDefaultState() {
        messageTextView.text = "Сообщение..."
        messageTextView.textColor = #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1)
    }
    
    private func setupTextView() {
        setupTextViewDefaultState()
        messageTextView.delegate = self
        messageTextView.layer.masksToBounds = true
    }
    
    private func setupConversation() {
        conversation.messagesTableView = self.tableView
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        guard let keyboardFrame = sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardHeight: CGFloat
        if #available(iOS 11.0, *) {
            keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
        } else {
            keyboardHeight =  keyboardFrame.cgRectValue.height
        }
        
        self.view.frame.origin.y = -1.0 * keyboardHeight
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let radius = cornerRadius ?? self.messageTextView.layer.frame.height / 2.0
        cornerRadius = radius
        sendButton.layer.cornerRadius = radius
        self.messageTextView.layer.cornerRadius = radius
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        setupTextViewDefaultState()
        messageTextView.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
        if let text = messageTextView.text  {
            if text.count == 0 {return}
            if conversation.online {
                conversation.sendMessage(text: text)
            }
        }
        setupTextViewDefaultState()
        messageTextView.resignFirstResponder()
    }
    
}
