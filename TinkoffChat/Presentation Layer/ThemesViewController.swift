//
//  ThemesViewController.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 22.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

class ThemesViewController: UIViewController {
    
    var model: Themes?
    var themeDidChanged: ((Theme) -> Void)?
    
    private static var backgroundColorURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("theme-backgroundColor")
    }
    private static var tintColorURL : URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("theme-tintColor")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UINavigationBar.appearance().barTintColor
        model = Themes()
        model?.theme1 = Theme.sharedBlack()
        model?.theme2 = Theme.sharedWhite()
        model?.theme3 = Theme.sharedChampain()
    }
    private func changeTheme(to theme: Theme) {
        view.backgroundColor = theme.backgroundColor
        let currentBar = self.navigationController?.navigationBar
        currentBar?.barTintColor = theme.backgroundColor
        currentBar?.tintColor = theme.tintColor
        currentBar?.titleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.tintColor]
        themeDidChanged?(theme)
    }
    
    static func set(theme newTheme: Theme, to bar: UINavigationBar) {
        bar.tintColor = newTheme.tintColor
        bar.barTintColor = newTheme.backgroundColor
        bar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: newTheme.tintColor]
    }
    
    static func getStoredTheme() -> Theme {
        let backgroundColorPath = ThemesViewController.backgroundColorURL.path
        let tintColorPath = ThemesViewController.tintColorURL.path
        
        let theme: Theme
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
    
    @IBAction func closeAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func theme1Action(_ sender: UIButton) {
        if let model = model {
            changeTheme(to: model.theme1)
        }
    }
    @IBAction func theme2Action(_ sender: UIButton) {
        if let model = model {
            changeTheme(to: model.theme2)
        }
    }
    @IBAction func theme3Action(_ sender: UIButton) {
        if let model = model {
            changeTheme(to: model.theme3)
        }
    }
}
