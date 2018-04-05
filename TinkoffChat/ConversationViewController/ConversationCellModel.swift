//
//  ConversationCellModel.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 10.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import Foundation

protocol ConversationCellConfiguration {
    var name: String {get set}
    var message: String? {get set}
    var date: Date? {get set}
    var online: Bool {get set}
    var hasUnreadMessages: Bool {get set}
}

struct ConversationCellModel: ConversationCellConfiguration {
    
    var name: String
    var message: String?
    var date: Date?
    var online = true
    var hasUnreadMessages = true
    
    private static var storedNames: [String] = [
        "Олег Тиньков",
        "Оливер Хьюз",
        "Сергей Пирогов",
        "Вадим Стасовский",
        "Светлана Устиловская",
        "Юлия Немчёнок",
        "Екатерина Шестимерова",
        "Алексей Зверев",
        "Дмитрий Терехин",
        "Олег Самойлов",
        "Даниил Гончар",
        "Георгий Фесенко",
        "Александр Лыков"
    ]
    
    private static let storedMessages: [String?] = [
        "Привет!",
        "Как дела?",
        "Ну такое..",
        "Пожалуй, лучший кэшбэк в России",
        "Сегодня дедлайн!",
        "Это костыль!",
        nil
    ]
    private static let storedDates: [Date] = [
        Date(),
        Calendar.current.date(byAdding: .hour, value: -1, to: Date())!,
        Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        Calendar.current.date(byAdding: .day, value: -2, to: Date())!
    ]
    
    private static func getName() -> String? {
        guard ConversationCellModel.storedNames.count > 0 else {
            return nil
        }
        let index = Int(arc4random_uniform(UInt32(ConversationCellModel.storedNames.count)))
        let elem = ConversationCellModel.storedNames[index]
        ConversationCellModel.storedNames.remove(at: index)
        return elem
    }
    
    static func getNewConversation(online status: Bool, andNotRead isRead: Bool) -> ConversationCellModel? {
        guard let someName = getName() else {
                return nil
        }
        return ConversationCellModel(name: someName,
                                     message: storedMessages.showRandomElement,
                                     date: storedDates.showRandomElement,
                                     online: status,
                                     hasUnreadMessages: isRead
        )
    }
}

extension Array {
    var showRandomElement: Element {
        get {
            return self[Int(arc4random_uniform(UInt32(self.count)))]
        }
    }
}
