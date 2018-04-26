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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
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

