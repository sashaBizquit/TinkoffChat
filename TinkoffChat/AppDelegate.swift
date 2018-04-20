//
//  AppDelegate.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 21.02.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var storeManager: StoreManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let newManager = StoreManager()
        if newManager.getUser(withId: User.me.id) == nil {
            var user = User.me
            user.name = "Александр Лыков"
            user.info = "MSU = 🧠, Tinkoff = 💛"
            assert(newManager.put(user: user, current: true), "Не смогли положить себя")
            AppDelegate.storeManager = newManager
            //self.setTestConversations(to: newManager.saveContext)
        } else {
            AppDelegate.storeManager = newManager
        }
        
        return true
    }
    
    private func setTestConversations(to context: NSManagedObjectContext ) {
        
        let conversationRequest = NSFetchRequest<CDConversation>(entityName: "CDConversation")
        
        if let conversationCount = try? context.fetch(conversationRequest).count,
            conversationCount < 1 {
            print("ща сохраним")
            let boolArray = [false,false,false]
            outerloop: for status in boolArray {
                for readStatus in boolArray.reversed() {
                    guard let newChat = ConversationProvider.getNewConversation(online: status, andNotRead: readStatus) else {
                        break outerloop
                    }
                    
                    let conversationRequest = NSFetchRequest<CDConversation>(entityName: "CDConversation")
                    let conversationId = try? context.fetch(conversationRequest).count + 1
                    let conversation = NSEntityDescription.insertNewObject(forEntityName: "CDConversation", into: context) as! CDConversation
                    conversation.id = Int64(conversationId ?? 0)
                    conversation.online = newChat.online
                    conversation.hasUnreadMessages = readStatus
                    conversation.date = newChat.date
                    
                    if let text = newChat.message {
                        let messageRequest = NSFetchRequest<CDMessage>(entityName: "CDMessage")
                        let messageId = try? context.fetch(messageRequest).count + 1
                        let message = NSEntityDescription.insertNewObject(forEntityName: "CDMessage", into: context) as! CDMessage
                        message.text = text
                        message.id = String(messageId ?? 0)
                        message.date = newChat.date
                        message.incoming = status
                        conversation.text = text
                        message.conversation = conversation
                    }
                    
                    let userRequest = NSFetchRequest<CDUser>(entityName: "CDUser")
                    let userId = try? context.fetch(userRequest).count + 1
                    let user = NSEntityDescription.insertNewObject(forEntityName: "CDUser", into: context) as! CDUser
                    user.id =  String(userId ?? 0)
                    user.name = newChat.name
                    conversation.interlocutor = user
                    
                    
                    //        self.interlocutor = User(id: newChat.name, name: newChat.name)
                    //        self.online = newChat.online
                    //        self.isUnread = readStatus
                    //
                    //        if let message = newChat.message {
                    //            messages = [Message]()
                    //            messages!.append(Message(text: message, date: newChat.date, sender: interlocutor, isIncoming: true))
                    //        }
                    //        lastActivityDate = newChat.date
                    print("положили в сейв контекст")
                }
            }
            
            AppDelegate.storeManager.save{ flag in
                if (flag) {
                    //                    //DispatchQueue.main.async {
                    //                        try? self?.fetchedResultController?.performFetch()
                    //                    //}
                    print("СОХРАНИЛ БОТОСООБЩЕНИЯ")
                } else {
                    print("НЕ СОХРАНИЛ БОТОСООБЩЕНИЯ")
                }
            }
        }
        
    }
    
    // MARK: - Photo Access Around the App
    
    static func getStoredImageURLForUser(withId id: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("profile-\(id)-image")
    }
    
    static func getStoredImageForUser(withId id: String) -> UIImage? {
        let storedImageURL = AppDelegate.getStoredImageURLForUser(withId: id)
        do {
            let imageData = try Data(contentsOf: storedImageURL)
            guard let storedImage = UIImage(data: imageData) else {
                return nil
            }
            return storedImage
        } catch {
            return nil
        }
    }

}

