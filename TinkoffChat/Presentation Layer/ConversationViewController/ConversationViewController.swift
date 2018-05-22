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
    private var titleLabel: UILabel?
    private let activeButtonColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
    private let inactiveButtonColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
    private let activeTitleColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    private let inactiveTitleColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
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
        messageTextView.text = ""
        messageTextView.textColor = #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1)
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.sendButton.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        }
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didFoundUser), name: .didFoundUser, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didLostUser), name: .didLostUser, object: nil)
    }
    
    @objc private func didFoundUser() {
        DispatchQueue.main.async { [weak self] in
            self?.activeTitleState()
            self?.sendButton.isEnabled = true
            if (self?.messageTextView.text.count != 0) {
                self?.activeSendButtonState()
            }
        }
    }
    
    @objc private func didLostUser() {
        DispatchQueue.main.async { [weak self] in
            self?.inactiveTitleState()
            self?.sendButton.isEnabled = false
            if (self?.messageTextView.text.count != 0) {
                self?.inactiveSendButtonState()
            }
        }
    }
    
    @objc private func keyboardWillShow(sender: NSNotification) {
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
    
    @objc private func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (conversation.online) {
//            titleLabel?.transform = CGAffineTransform(scaleX: 1.0/1.1, y: 1.0/1.1)
//            titleLabel?.textColor = self.inactiveTitleColor
            configureTitle()
            activeTitleState()
        }
    }
    
    private func configureTitle() {
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        titleLabel?.text = self.title
        titleLabel?.textColor = self.navigationController?.navigationBar.tintColor
        titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 20.0)
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.textAlignment = .center
        self.navigationController?.navigationBar.topItem?.titleView = titleLabel
        //titleLabel?.sizeToFit()
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
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = messageTextView.text  {
            if text.count != 0 {
                if (sendButton.backgroundColor == activeButtonColor || conversation.online == false) {return}
                self.activeSendButtonState()
            } else {
                if (sendButton.backgroundColor == inactiveButtonColor) {return}
                self.inactiveSendButtonState()
            }
        }
    }
    
    private func activeSendButtonState() {
        if (!self.sendButton.isEnabled) {return}
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let strongSelf = self else {return}
            strongSelf.sendButton.backgroundColor = strongSelf.activeButtonColor
            strongSelf.sendButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }, completion:  { [weak self] flag in
                guard let strongSelf = self else {return}
                UIView.animate(withDuration: 0.5, animations: { [weak strongSelf] in
                    strongSelf?.sendButton.transform = CGAffineTransform(scaleX: 1/1.15, y: 1/1.15)
                    }, completion:  { [weak strongSelf] flag in
                        strongSelf?.sendButton.isEnabled = true
                })
        })
    }
    
    private func inactiveSendButtonState() {
        if (self.sendButton.isEnabled) {return}
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.sendButton.backgroundColor = self?.inactiveButtonColor
        }
    }
    
    private func activeTitleState() {
        if (self.titleLabel?.textColor == self.activeTitleColor) {
            
            return
        }
        //self.titleLabel?.textColor = self.activeTitleColor
        UIView.animate(withDuration: 1) { [weak self] in
            guard let strongSelf = self else {return}
            
            strongSelf.titleLabel?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            strongSelf.titleLabel?.textColor = strongSelf.activeTitleColor
        }
    }
    
    private func inactiveTitleState() {
        if (self.titleLabel?.textColor != self.activeTitleColor) {
            
            return
        }
        UIView.animate(withDuration: 1) { [weak self] in
            guard let strongSelf = self, let label = strongSelf.titleLabel else {return}
            label.transform = CGAffineTransform(scaleX: 1.0/1.1, y: 1.0/1.1)
            label.textColor = strongSelf.inactiveTitleColor
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.topItem?.titleView = nil
        NotificationCenter.default.removeObserver(self)
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
