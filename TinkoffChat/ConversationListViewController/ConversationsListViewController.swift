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
        return documentsDirectory.appendingPathComponent("theme-backgroundColor")
    }
    private static var tintColorURL : URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("theme-tintColor")
    }
    
    @IBOutlet weak var profileButton: UIButton!
    
    enum SectionsNames: String {
        case Online = "Онлайн", Offline = "Офлайн"
    }
    
    private var manager: ConversationsManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.set(theme: getStoredTheme())
        self.setManager()
        self.setDrawingOptions(forButton: profileButton)
        
    }
    
    private func setManager() {
        manager = ConversationsManager(with: self.tableView)
        tableView.dataSource = manager
    }
    
    private func setDrawingOptions(forButton button: UIButton) {
        self.title = "TinkoffChat"
        button.layer.masksToBounds = true
        let height = self.navigationController!.navigationBar.frame.height
        button.heightAnchor.constraint(equalToConstant: height / CGFloat(2).squareRoot()).isActive = true
        button.widthAnchor.constraint(equalToConstant: height / CGFloat(2).squareRoot()).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileButton.layer.cornerRadius = profileButton.frame.width / 2.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let image = AppDelegate.getStoredImageForUser(withId: User.me.id)
        profileButton.setImage(image ?? #imageLiteral(resourceName: "placeholder-user"), for: .normal)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let segueId = segue.identifier else {
            print("Нет id у segue")
            return
        }
        switch segueId {
            case "toProfile":
                prepareProfile(segue: segue)
                break
            case "toConversation":
                prepareConversation(segue: segue, sender: sender)
                break
            case "toThemePicker":
                prepareTheme(segue: segue)
                break
            default:
                return
        }
    }
    
    private func prepareProfile(segue: UIStoryboardSegue) {
        if let navigationVC = segue.destination as? UINavigationController,
            let profileVC = navigationVC.topViewController as? ProfileViewController {
            profileVC.id = User.me.id
        }
    }
    
    private func prepareConversation(segue: UIStoryboardSegue, sender: Any?) {
        if let conversationVC = segue.destination as? ConversationViewController,
            let conversationCell = sender as? ConversationListCell,
            let selectedIndex = tableView.indexPath(for: conversationCell) {
            guard let conversationId = manager.getIdForIndexPath(selectedIndex) else {
                print("Не получили id")
                return
            }
            conversationVC.conversation = Conversation(withManager: manager,
                                                       userId: conversationId)
            conversationCell.hasUnreadMessages = false
        }
    }
    
    private func prepareTheme(segue: UIStoryboardSegue) {
        if let navigationVC = segue.destination as? UINavigationController,
            let themesVC = navigationVC.topViewController as? ThemesViewController {
            themesVC.themeDidChanged = { [weak self] (theme: Theme) in
                self?.set(theme: theme)
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
    private func set(theme: Theme) {
        ThemesViewController.set(theme: theme, to: self.navigationController!.navigationBar)
        ThemesViewController.set(theme: theme, to: UINavigationBar.appearance())
    }
}
