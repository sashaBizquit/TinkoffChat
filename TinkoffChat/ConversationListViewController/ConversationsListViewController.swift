//
//  ConversationsListTableViewController.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 10.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

class ConversationsListViewController: UITableViewController {
    
    private static var backgroundColorURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("profile-theme-backgroundColor")
    }
    private static var tintColorURL : URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("profile-theme-tintColor")
    }
    
    @IBOutlet weak var profileButton: UIButton!
    
    enum SectionsNames: String {
        case Online = "Онлайн", Offline = "Офлайн"
    }
    
    private var dialogs: Conversations!
    private func getConversations()-> Conversations {
        return Conversations()
    }
    
    private func getStoredTheme() -> Theme {
        let backgroundColorPath = ConversationsListViewController.backgroundColorURL.path
        let tintColorPath = ConversationsListViewController.tintColorURL.path
        
        let theme: Theme!
        if let backgroundColor =  NSKeyedUnarchiver.unarchiveObject(withFile: backgroundColorPath) as? UIColor,
            let tintColor = NSKeyedUnarchiver.unarchiveObject(withFile: tintColorPath) as? UIColor {
            theme = Theme()
            theme.backgroundColor = backgroundColor
            theme.tintColor = tintColor
        } else {
            theme = Theme.sharedWhite()
        }
        return theme
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logThemeChanging(selectedTheme: getStoredTheme())
        
        dialogs = getConversations()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
        
        let height = self.navigationController!.navigationBar.frame.size.height / CGFloat(2).squareRoot()
        profileButton.widthAnchor.constraint(equalToConstant: height).isActive = true
        profileButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        profileButton.layer.masksToBounds = true
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? dialogs.onlineConversations!.count : dialogs.offlineConversations!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: ConversationListCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "conversationIdentifier", for: indexPath) as? ConversationListCell {
            cell = dequeuedCell
        } else {
            cell = ConversationListCell()
        }
        let conversation = indexPath.section == 0 ?  dialogs.onlineConversations![indexPath.row] : dialogs.offlineConversations![indexPath.row]
        
        cell.name = conversation.interlocutor
        cell.message = conversation.messages == nil ? ConversationListCell.noMessagesConst : conversation.lastMessage!.text
        cell.date = conversation.lastMessage?.date
        cell.hasUnreadMessages = conversation.hasUnreadMessages
        cell.online = conversation.online

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? SectionsNames.Online.rawValue : SectionsNames.Offline.rawValue
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfile" {
            if let navigationVC = segue.destination as? UINavigationController,
                let profileVC = navigationVC.topViewController as? ProfileViewController {
                    profileVC.id = 0
            }
        } else if segue.identifier == "toConversation" {
            if let conversationVC = segue.destination as? ConversationViewController,
                let conversationCell = sender as? ConversationListCell,
                let selectedIndex = tableView.indexPath(for: conversationCell) {
                
                conversationCell.hasUnreadMessages = false
                let conversation = selectedIndex.section == 0 ? dialogs.onlineConversations![selectedIndex.row] : dialogs.offlineConversations![selectedIndex.row]
                conversationVC.conversation = conversation
            }
        } else if segue.identifier == "toThemePicker",
            let navigationVC = segue.destination as? UINavigationController,
            let themesVC = navigationVC.topViewController as? ThemesViewController {
                    themesVC.themeDidChanged = { [weak self] (theme: Theme) in
                        self?.logThemeChanging(selectedTheme: theme)
                        self?.saveTheme(selectedTheme: theme)
                    }
            }
    }
    
    func saveTheme(selectedTheme: Theme) {
        DispatchQueue.global().async { [weak selectedTheme] in
            guard let strongTheme = selectedTheme else {return}
            let backgroundColor = strongTheme.backgroundColor!
            let backgroundColorData =  NSKeyedArchiver.archivedData(withRootObject: backgroundColor)
            try? backgroundColorData.write(to: ConversationsListViewController.backgroundColorURL)
        
            let tintColor = strongTheme.tintColor!
            let tintColorData = NSKeyedArchiver.archivedData(withRootObject: tintColor)
            try? tintColorData.write(to: ConversationsListViewController.tintColorURL)
        }
    }
    // MARK: - ThemesViewControllerDelegate

    private func logThemeChanging(selectedTheme: Theme) {
        ThemesViewController.set(theme: selectedTheme, to: self.navigationController!.navigationBar)
        ThemesViewController.set(theme: selectedTheme, to: UINavigationBar.appearance())
    }
}
