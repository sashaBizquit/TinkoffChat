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
    
    private var cManager: ConversationsManager?
    private var storeManager: StoreManagerProtocol?
    
    //var flag = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDesign()
        self.setManagers()
        self.setDrawingOptions(forButton: profileButton)
        self.addRecognizer()
    }
    
    private func addRecognizer() {
        let gestureView = UIView(frame: UIApplication.shared.windows.first!.bounds)
        gestureView.backgroundColor = .clear
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        recognizer.cancelsTouchesInView = false
        gestureView.addGestureRecognizer(recognizer)
        self.view.addSubview(gestureView)
    }

    @objc private func longPress(_ sender: UILongPressGestureRecognizer) {
        
        let point = sender.location(in: self.view)
        switch sender.state {
        case .began:
            print("began")
//            if (!flag) {
//                return
//            } else {
//                flag = false
//            }
            let imageView = UIImageView(image: #imageLiteral(resourceName: "tinkoff"))
            imageView.frame = CGRect(origin: point, size: CGSize(width: 100, height: 100))
            imageView.sizeToFit()
            print(point)
            self.view.addSubview(imageView)
            //        DispatchQueue.main.async {
            //            UIView.animate(withDuration: 2, animations: {[weak self] in
            //                guard let strongSelf = self else {return}
            //                imageView.frame.origin = CGPoint(x: strongSelf.view.frame.midX, y: strongSelf.view.frame.midY)
            //            }) { [weak self] (finished) in
            //                self?.flag = true
            //                imageView.removeFromSuperview()
            //            }
            //        }
            break;
        case .cancelled:
            print("cancelled")
            break;
        case .ended:
            print("ended")
            break;
        default:
            break
        }
        
        
    }
    
    private func setDesign() {
        let theme = ThemesViewController.getStoredTheme()
        self.setTheme(theme)
    }
    
    private func setManagers() {
        let newManager = StoreManager()
        if newManager.getUser(withId: User.me.id) == nil {
            var user = User.me
            user.name = "Александр Лыков"
            
            newManager.findOrInsertUser(withId: user.id, name: user.name) { user in
                user.info = "MSU = 🧠, Tinkoff = 💛"
            }
        }
        self.storeManager = newManager
        guard let sManager = self.storeManager else {
            assert(false, "ConversationsListViewController: store manager wasn't found")
        }
        cManager = ConversationsManager(with: self.tableView, andManager: sManager)
        tableView.dataSource = cManager
    }
    
    private func setDrawingOptions(forButton button: UIButton) {
        self.title = "Чаты"
        self.tableView.rowHeight = 80
        button.layer.masksToBounds = true
        let height = self.navigationController?.navigationBar.frame.height ?? 20
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversationVC = prepareConversationController(indexPath: indexPath)
        self.navigationController?.pushViewController(conversationVC, animated: true)
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
            profileVC.storeManager = storeManager
        }
    }
    
    private func prepareConversationController(indexPath: IndexPath) -> ConversationViewController {
        guard let conversationId = cManager?.getIdForIndexPath(indexPath) else {
            assert(false, "Не получили conversationId для \(indexPath)")
        }
        guard let sManager = storeManager else {
            assert(false, "ConversationsListViewController: storeManager not defined")
        }
        let conversation = Conversation(withConversationsManager: cManager, storeManager: sManager, conversationId)
        cManager?.didReadConversation(withId: conversationId)
        let conversationVC = ConversationViewController(withConversation: conversation)
        return conversationVC
    }
    
    private func prepareTheme(segue: UIStoryboardSegue) {
        if let navigationVC = segue.destination as? UINavigationController,
            let themesVC = navigationVC.topViewController as? ThemesViewController {
            themesVC.themeDidChanged = { [weak self] (theme: Theme) in
                self?.setTheme(theme)
                self?.saveTheme(selectedTheme: theme)
            }
        }
    }
    
    // MARK: - Theme
    func saveTheme(selectedTheme: Theme) {
        DispatchQueue.global().async { [weak selectedTheme] in
            guard let strongTheme = selectedTheme else {return}
            let backgroundColor = strongTheme.backgroundColor ?? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            let backgroundColorData =  NSKeyedArchiver.archivedData(withRootObject: backgroundColor)
            try? backgroundColorData.write(to: ConversationsListViewController.backgroundColorURL)
        
            let tintColor = strongTheme.tintColor ?? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            let tintColorData = NSKeyedArchiver.archivedData(withRootObject: tintColor)
            try? tintColorData.write(to: ConversationsListViewController.tintColorURL)
        }
    }
    
    // MARK: - ThemesViewControllerDelegate
    private func setTheme(_ theme: Theme) {
        guard let navigationBar = self.navigationController?.navigationBar else {
            assert(false, "ConversationsListViewController has no access to navigationBar")
        }
        
        ThemesViewController.set(theme: theme, to: navigationBar)
        ThemesViewController.set(theme: theme, to: UINavigationBar.appearance())
    }
}
