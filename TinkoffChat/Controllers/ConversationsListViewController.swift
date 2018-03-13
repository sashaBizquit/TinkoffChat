//
//  ConversationsListTableViewController.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 10.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

class ConversationsListViewController: UITableViewController {

    @IBOutlet weak var profileButton: UIButton!
    
    private var conversations: [SectionsNames: [ConversationCellModel]] = [.Online: [ConversationCellModel](), .Offline: [ConversationCellModel]()]
    
    enum SectionsNames: String {
        case Online = "Онлайн", Offline = "Офлайн"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let boolArray = [true,false,true,true]
        outerloop: for status in boolArray {
            for readStatus in boolArray.reversed() {
                if let newChat = ConversationCellModel.getNewConversation(online: status, andNotRead: readStatus) {
                    newChat.online ? conversations[.Online]!.append(newChat): conversations[.Offline]!.append(newChat)
                } else {
                    break outerloop
                }
            }
        }
        
        conversations[.Online]!.sort {$0.date! > $1.date!}
        conversations[.Offline]!.sort {$0.date! > $1.date!}
        
        let height = self.navigationController!.navigationBar.frame.size.height / CGFloat(2).squareRoot()
        profileButton.widthAnchor.constraint(equalToConstant: height).isActive = true
        profileButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        profileButton.layer.masksToBounds = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileButton.layer.cornerRadius = profileButton.frame.width / 2.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "TinkoffChat"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = ""
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return conversations.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? conversations[.Online]!.count : conversations[.Offline]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: ConversationListCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "conversationIdentifier", for: indexPath) as? ConversationListCell {
            cell = dequeuedCell
        } else {
            cell = ConversationListCell()
        }
        let cellData = indexPath.section == 0 ? conversations[.Online]![indexPath.row] : conversations[.Offline]![indexPath.row]
        
        cell.name = cellData.name
        cell.message = cellData.message
        cell.date = cellData.date
        cell.hasUnreadMessages = cellData.hasUnreadMessages
        cell.online = cellData.online

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? SectionsNames.Online.rawValue : SectionsNames.Offline.rawValue
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfile" {
            if let navigationVC = segue.destination as? UINavigationController,
                let profileVC = navigationVC.topViewController as? ProfileViewController {
                profileVC.content.0 = "Александр Лыков"
                profileVC.content.1 = "Love 🇷🇺 Live in MSU, looking for iOS family 📟"
            }
        } else if segue.identifier == "toConversation" {
            if let conversationVC = segue.destination as? ConversationViewController,
                let conversation = sender as? ConversationListCell{
                conversationVC.interlocutor = conversation.name!
                conversation.hasUnreadMessages = false
                if let message = conversation.message {
                    conversationVC.messages.insert((message, false), at: conversationVC.messages.endIndex)
                } else {
                    conversationVC.messages.removeAll()
                }
            }
        }
    }

}