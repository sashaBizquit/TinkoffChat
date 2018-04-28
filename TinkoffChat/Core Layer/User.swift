//
//  User.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 28.04.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import Foundation

protocol UserProtocol {
    var id: String {get set}
    var info: String? {get set}
    var photoURL: URL? {get set}
    var name: String? {get set}
    static var me: UserProtocol {get}
    
    init(id newId: String, name newName: String?)
    init(id newId: String, name newName: String?, photoURL url: URL?, info newInfo: String?)
}

struct User: UserProtocol {
    var id: String
    var info: String?
    var photoURL: URL?
    var name: String?
    static var me: UserProtocol = {
        return User(id: MultipeerCommunicator.myPeerId.displayName, name: MultipeerCommunicator.userName)
    }()
    init(id newId: String, name newName: String?) {
        self.init(id: newId, name: newName, photoURL: nil, info: nil)
    }
    init(id newId: String, name newName: String?, photoURL url: URL?, info newInfo: String?) {
        id = newId
        name = newName
        info = newInfo
        photoURL = url
    }
}
