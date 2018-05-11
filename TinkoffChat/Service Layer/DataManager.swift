//
//  GCDDataManager.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 28.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import Foundation

class DataManager {
    
    private var user: User?
    private var storeManager: StoreManagerProtocol
    
    weak var delegate: UIViewController!
    var isImageChanged = true
    
    init(withId id: String, andStoreManager sManager: StoreManagerProtocol) {
        storeManager = sManager
        user = User(id: id, name: nil)
        user?.photoURL = AppDelegate.getStoredImageURLForUser(withId: id)
    }
    
    //MARK: - Saving Methods
    
    private func savedMessage(withTitle title: String, message: String?, additionAction: UIAlertAction?, _ indicator: UIActivityIndicatorView) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        if additionAction != nil {
            alertController.addAction(additionAction!)
        }
        
        let cancelAction = UIAlertAction(title: "Ок", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async { [weak self, weak indicator] in
            indicator?.removeFromSuperview()
            self?.delegate.present(alertController, animated: true, completion: nil)
        }
    }
    
    func save(_ name: String, _ info: String, _ image: UIImage) {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.delegate.view.addSubview(activityIndicator)
        activityIndicator.frame = self.delegate.view.bounds
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self, weak activityIndicator] in
            guard let strongSelf = self,
                let user = strongSelf.user,
                let strongActivator = activityIndicator else {
                    return
            }
            
            let repeatAction = UIAlertAction(title: "Повторить", style: .default) { [weak strongSelf, weak image] action in
                guard let strongSelf = strongSelf else { return }
                guard let strongImage = image else { return }
                strongSelf.save(name, info, strongImage)
            }
            
            var changesHappened = false
            let currentUser = strongSelf.user
            if (currentUser?.name != name) {
                strongSelf.user?.name = name
                changesHappened = true
            }
            if (currentUser?.info != info) {
                strongSelf.user?.info = info
                changesHappened = true
            }
            
            if (!changesHappened && !strongSelf.isImageChanged) {
                return
            }
            strongSelf.storeManager.putNewUser(withId: user.id, name: user.name) { [weak strongSelf] _ in
                strongSelf?.storeManager.save { [weak strongSelf] flag in
                    guard let strongSelf = strongSelf else {
                        assert(false, "DataManager: save(): DataManager not found")
                    }
                    if flag {
                        strongSelf.savedMessage(withTitle: "Данные сохранены",
                                                message: nil,
                                                additionAction: nil,
                                                strongActivator)
                    } else {
                        strongSelf.savedMessage(withTitle: "Ошибка",
                                                message: "Не удалось сохранить данные",
                                                additionAction: repeatAction,
                                                strongActivator)
                    }
                }
            }
        }
    }
    

    
    //MARK: - User Getter
    
    func getStoredUser() -> User? {
        guard let id = user?.id else {
            assert(false, "User not found")
            return nil
        }
        return storeManager.getUser(withId: id)
    }
    
    //MARK: - Photo Manager
    
    func saveImage(_ newImage: UIImage) throws {
        if !isImageChanged { return }
        
        guard let newImageData = UIImagePNGRepresentation(newImage) else {
            throw NSError(domain: "Can't convert new image", code: -1, userInfo: nil)
        }
        guard let id = user?.id else {
            assert(false, "User not found")
            return
        }
        try newImageData.write(to: AppDelegate.getStoredImageURLForUser(withId: id), options: .atomic)
        isImageChanged = false
    }
}
