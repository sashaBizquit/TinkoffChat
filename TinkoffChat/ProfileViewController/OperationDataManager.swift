//
//  OperationDataManager.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 28.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import Foundation

class OperationDataManager: Operation {
    
    private var storedNameURL: URL {
        get {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            return documentsDirectory.appendingPathComponent("profile-\(profileId)-name")
        }
    }
    private var storedDescriptionURL: URL {
        get {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            return documentsDirectory.appendingPathComponent("profile-\(profileId)-description")
        }
    }
    private var storedImageURL: URL {
        get {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            return documentsDirectory.appendingPathComponent("profile-\(profileId)-image")
        }
    }
    
    private var profileId: UInt!
    var profileName: String?
    var profileDescription: String?
    var profileImage: UIImage?
    var isImageChanged = true
    weak var delegate: UIViewController!
    weak var indicator: UIActivityIndicatorView?
    
    override convenience init() {
        self.init(withId: 0, name: nil, description: nil, image: nil)
    }
    
    init(withId id: UInt, name: String?, description: String?, image: UIImage?) {
        profileId = id
        self.profileName = name
        self.profileDescription = description
        self.profileImage = image
        super.init()
    }
    
    private func savedMessage(withTitle title: String, message: String?, additionAction: UIAlertAction?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        if additionAction != nil {
            alertController.addAction(additionAction!)
        }
        
        let cancelAction = UIAlertAction(title: "Ок", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        OperationQueue.main.addOperation {
            self.indicator?.removeFromSuperview()
            self.delegate.present(alertController, animated: true, completion: nil)
        }
        
        // < только ради ДЗ/ТЗ - потом удалить этот код
        
        // имя by контроллер = имя by память
        self.getStoredName { [weak self] name in
            guard let strongSelf = self,
                let profileVC = strongSelf.delegate as? ProfileViewController else {return}
            profileVC.nameTextField.text = name
        }
        
        // описание by контроллер = описание by память
        self.getStoredDescription { [weak self] description in
            guard let strongSelf = self,
                let profileVC = strongSelf.delegate as? ProfileViewController else {return}
            profileVC.descriptionTextView.text = description
        }
        // картинка by контроллер = картинка by память
        self.getStoredImage { [weak self] image in
            guard let strongSelf = self,
                let profileVC = strongSelf.delegate as? ProfileViewController else {return}
            profileVC.profileImageView.image = image
        }
        // только ради ДЗ/ТЗ - потом удалить этот код >
    }
    
    //MARK: - Serial Save
    
    private func saveName() throws {
        if profileName ==  nil { return }
        try profileName!.write(to: storedNameURL, atomically: true, encoding: .utf8)
    }
    
    private func saveDescription() throws {
        if profileDescription ==  nil { return }
        try profileDescription!.write(to: storedDescriptionURL, atomically: true, encoding: .utf8)
    }
    
    private func saveImage() throws {
        if !isImageChanged { return }
        guard let newImageData = UIImagePNGRepresentation(profileImage!) else {
            throw NSError(domain: "Can't convert new image", code: -1, userInfo: nil)
        }
        
        try newImageData.write(to: storedImageURL, options: .atomic)
        isImageChanged = false
    }
    
    //MARK: - Concurrent Getters
    
    func getStoredName(execute work: @escaping CompletionStringHandler) {
            guard let storedName = self.getStoredName() else { return }
            OperationQueue.main.addOperation {work(storedName)}
    }
    
    func getStoredDescription(execute work: @escaping CompletionStringHandler) {
            guard let storedDescription = self.getStoredDescription() else { return }
            OperationQueue.main.addOperation {work(storedDescription)}
    }
    
    func getStoredImage(execute work: @escaping CompletionImageHandler) {
            guard let storedImage = self.getStoredImage() else { return }
            OperationQueue.main.addOperation {work(storedImage)}
    }
    
    
    //MARK: - Serial Getters
    
    private func getStoredName() -> String? {
        //if profileName != nil {return profileName}
        do {
            let storedName = try String(contentsOf: storedNameURL)
            return storedName
        } catch {
            return nil
        }
    }
    
    private func getStoredDescription() -> String? {
        //if profileDescription != nil {return profileDescription}
        do {
            let storedDescription = try String(contentsOf: storedDescriptionURL)
            return storedDescription
        } catch {
            return nil
        }
    }
    
    private func getStoredImage() -> UIImage? {
        //if profileImage != nil {return profileImage}
        do {
            let imageData = try Data(contentsOf: storedImageURL)
            guard let storedImage = UIImage(data: imageData) else { return nil }
            return storedImage
        } catch {
            return nil
        }
    }
    
    // MARK: - Operation
    
    public enum State: String {
        case ready, executing, finished
        
        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }
    
    public var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
    
    override func main() {
        let repeatAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] action in
            guard let strongSelf = self else { return }
            strongSelf.main()
        }
        
        do {
            try self.saveName()
            try self.saveDescription()
            try self.saveImage()
            self.savedMessage(withTitle: "Данные сохранены",
                              message: nil,
                              additionAction: nil)
        } catch {
            self.savedMessage(withTitle: "Ошибка",
                              message: "Не удалось сохранить данные",
                              additionAction: repeatAction)
        }
        self.state = .finished
    }
    
    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        main()
        state = .executing
    }
    
    override func cancel() {
        super.cancel()
        state = .finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
}
