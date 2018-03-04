//
//  AppDelegate.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 21.02.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

//extension Optional where Wrapped == UIApplicationState {
//     public var description: String {
//        switch self {
//            case .some(.active): return "Active"
//            case .some(.background): return "Background"
//            case .some(.inactive): return "Inactive"
//            case .none: return "Not Running"
//        }
//    }
//}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

//    private var currentState: UIApplicationState?
//
//    private func stateChanging(to newStateName: UIApplicationState?, by functionDescription: String) {
//        let actionDescription = UIApplication.shared.applicationState != newStateName ? "is about to move": "has moved"
//        print("Application \(actionDescription) from \(currentState.description) to \(newStateName.description) state: " + functionDescription)
//        currentState = newStateName
//    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        window = UIWindow(frame: UIScreen.main.bounds)
//        if let _window = window {
//            _window.rootViewController = ViewController()
//            _window.makeKeyAndVisible()
//        }
//        stateChanging(to: .inactive, by: #function)
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
//        stateChanging(to: .inactive, by: #function)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
//        stateChanging(to: .background, by: #function)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
//        stateChanging(to: .inactive, by: #function)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
//        stateChanging(to: .active, by: #function)
    }

    func applicationWillTerminate(_ application: UIApplication) {
//        stateChanging(to: nil, by: #function)
    }

}

