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
    var getCurrentThemeBackroundColor: (()-> UIColor?)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = getCurrentThemeBackroundColor?()
        
        model = Themes()
        model?.theme1 = Theme.sharedBlack()
        model?.theme2 = Theme.sharedWhite()
        model?.theme3 = Theme.sharedChampain()
        
    }
    private func changeTheme(to theme: Theme) {
        view.backgroundColor = theme.backgroundColor
        themeDidChanged?(theme)
    }
    
    @IBAction func closeAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func theme1Action(_ sender: UIButton) {
        changeTheme(to: model!.theme1)
    }
    @IBAction func theme2Action(_ sender: UIButton) {
        changeTheme(to: model!.theme2)
    }
    @IBAction func theme3Action(_ sender: UIButton) {
        changeTheme(to: model!.theme3)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
    }
}
