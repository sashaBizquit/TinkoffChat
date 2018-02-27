//
//  ViewController.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 21.02.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private func viewChanging(with changesDescription: String, by functionDescription: String) {
        print("View \(changesDescription): " + functionDescription)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewChanging(with: "is about to appear", by: #function)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewChanging(with: "has appeared", by: #function)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewChanging(with: "is about to adjust subviews", by: #function)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewChanging(with: "has adjusted subviews", by: #function)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewChanging(with: "is about to disappear", by: #function)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewChanging(with: "has disappeared", by: #function)
    }

}

