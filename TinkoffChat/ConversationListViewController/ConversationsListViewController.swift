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
    
    private var conversations: Conversations = Conversations()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logThemeChanging(selectedTheme: getStoredTheme())
        
        tableView.dataSource = conversations
        conversations.tableViewController = self
        profileButton.layer.masksToBounds = true

        let height = self.navigationController!.navigationBar.frame.height
        
        profileButton.heightAnchor.constraint(equalToConstant: height / CGFloat(2).squareRoot()).isActive = true
        profileButton.widthAnchor.constraint(equalToConstant: height / CGFloat(2).squareRoot()).isActive = true
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
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
                let conversation = selectedIndex.section == 0 ? conversations.onlineConversations![selectedIndex.row] : conversations.offlineConversations![selectedIndex.row]
                conversationVC.conversation = conversation
                conversation.isUnread = false
                //conversationVC.conversation.tableViewController = conversationVC
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
    
    // MARK: - Theme
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
    
    // MARK: - ThemesViewControllerDelegate
    private func logThemeChanging(selectedTheme: Theme) {
        ThemesViewController.set(theme: selectedTheme, to: self.navigationController!.navigationBar)
        ThemesViewController.set(theme: selectedTheme, to: UINavigationBar.appearance())
    }
}
