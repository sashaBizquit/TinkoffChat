//
//  ConversationView.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 28.04.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

class ConversationView: UIView {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
