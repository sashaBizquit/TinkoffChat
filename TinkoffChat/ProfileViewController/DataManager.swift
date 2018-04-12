//
//  GCDDataManager.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 28.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import Foundation

class DataManager {
    private var profileName: String?
    private var profileInfo: String?
    private var profilePhoto: UIImage?
    private var profileId: UInt!
    private let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    private var storedNameURL: URL {
        return documentsURL.appendingPathComponent("profile-\(profileId)-name")
    }
    private var storedDescriptionURL: URL {
        return documentsURL.appendingPathComponent("profile-\(profileId)-description")
    }
    private var storedImageURL: URL {
        return documentsURL.appendingPathComponent("profile-\(profileId)-image")
    }
    
    weak var delegate: UIViewController!
    var isImageChanged = true
    
    convenience init() {
        self.init(withId: 0)
    }
    
    init(withId id: UInt) {
        profileId = id
        profileName = getStoredName()
        profileInfo = getStoredDescription()
        profilePhoto = getStoredImage()
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
    
    func save(_ name: String, _ description: String, _ image: UIImage) {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.delegate.view.addSubview(activityIndicator)
        activityIndicator.frame = self.delegate.view.bounds
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self, weak activityIndicator] in
            guard let strongSelf = self, let strongActivator = activityIndicator else { return }
            
            let repeatAction = UIAlertAction(title: "Повторить", style: .default) { [weak self, weak image] action in
                guard let strongSelf = self else { return }
                guard let strongImage = image else { return }
                strongSelf.save(name, description, strongImage)
            }
            
            do {
                try strongSelf.saveName(name)
                try strongSelf.saveDescription(description)
                try strongSelf.saveImage(image)
                strongSelf.savedMessage(withTitle: "Данные сохранены",
                             message: nil,
                             additionAction: nil,
                             strongActivator)
            } catch {
                strongSelf.savedMessage(withTitle: "Ошибка",
                             message: "Не удалось сохранить данные",
                             additionAction: repeatAction,
                             strongActivator)
            }
        }
    }
        
    private func saveName(_ newName: String) throws {
        if self.profileName == newName { return }
        try newName.write(to: storedNameURL, atomically: true, encoding: .utf8)
        self.profileName = newName
    }
    
    private func saveDescription(_ newDescription: String) throws {
        if self.profileInfo == newDescription { return }
        try newDescription.write(to: storedDescriptionURL, atomically: true, encoding: .utf8)
        self.profileInfo = newDescription
    }
    
    private func saveImage(_ newImage: UIImage) throws {
        
        if !isImageChanged { return }
        
        guard let newImageData = UIImagePNGRepresentation(newImage) else {
            throw NSError(domain: "Can't convert new image", code: -1, userInfo: nil)
        }
        
        try newImageData.write(to: storedImageURL, options: .atomic)
        isImageChanged = false
        self.profilePhoto = newImage
    }
    
    //MARK: - Serial Getters
    
    func getStoredName() -> String? {
        if profileName != nil {return profileName}
        do {
            let storedName = try String(contentsOf: storedNameURL)
            return storedName
        } catch {
            return profileName
        }
    }
    
    func getStoredDescription() -> String? {
        if profileInfo != nil {return profileInfo}
        do {
            let storedDescription = try String(contentsOf: storedDescriptionURL)
            return storedDescription
        } catch {
            return profileInfo
        }
    }
    
    func getStoredImage() -> UIImage? {
        if profilePhoto != nil {return profilePhoto}
        do {
            let imageData = try Data(contentsOf: storedImageURL)
            guard let storedImage = UIImage(data: imageData) else {
                return profilePhoto
            }
            return storedImage
        } catch {
            return profilePhoto
        }
    }
}
