//
//  ViewController.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 21.02.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//
import Photos
import UIKit

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    private var storedNameURL: URL {
        get {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            return documentsDirectory.appendingPathComponent("profile-\(content.0)-name")
        }
    }
    private var storedDescriptionURL: URL {
        get {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            return documentsDirectory.appendingPathComponent("profile-\(content.0)-description")
        }
    }
    private var storedImageURL: URL {
        get {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            return documentsDirectory.appendingPathComponent("profile-\(content.0)-image")
        }
    }
    
    var content = ("Name","Description")
    private var bottomLine: CALayer?
    
    override func viewDidLoad() {
        nameTextField.delegate = self
        nameTextField.text = content.0
        leftButton.titleLabel?.text = "Редактировать"
        rightButton.isHidden = true
        
        descriptionTextView.delegate = self
        descriptionTextView.text = content.1
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.clear.cgColor
        
        leftButton.layer.borderWidth = 1
        rightButton.layer.borderWidth = 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        descriptionTextView.endEditing(true)
        nameTextField.endEditing(true)
    }
    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        textField.layer.addSublayer(bottomLine!)
//        return true
//    }
    
    private func safeTrunc(of someString: String, offsetBy offset: Int) -> String {
        let safeOffset = min(offset,someString.endIndex.encodedOffset)
        let index = someString.index(someString.startIndex, offsetBy: safeOffset)
        return String(someString[..<index])
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = safeTrunc(of: textField.text!, offsetBy: 25)
    }
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        bottomLine?.removeFromSuperlayer()
//        return true
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        textView.layer.borderColor = UIColor.black.cgColor
//    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = safeTrunc(of: textView.text!, offsetBy: 300)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            self.view.frame.origin.y = -1.0 * keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        bottomLine = CALayer()
        bottomLine?.frame = CGRect(x: 0.0, y: nameTextField.frame.height - 1, width: nameTextField.frame.width, height: 1.0)
        //bottomLine?.backgroundColor = UIColor.clear.cgColor
        nameTextField.layer.addSublayer(bottomLine!)
        
        
        let imagesCornerRadius = CGFloat.minimum(editPhotoButton.frame.width, editPhotoButton.frame.height) / 2.0
        profileImage.layer.cornerRadius = imagesCornerRadius
        editPhotoButton.layer.cornerRadius = imagesCornerRadius
        
        let inset = imagesCornerRadius * (1.0 - 1.0/sqrt(2.0))
        editPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        
        let buttonsCornerRadius = leftButton.frame.height / 4.0
        descriptionTextView.layer.cornerRadius = buttonsCornerRadius
        //descriptionTextView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        leftButton.layer.cornerRadius = buttonsCornerRadius
        rightButton.layer.cornerRadius = buttonsCornerRadius
    }

    @IBAction func editPhoto(_ sender: UIButton) {
        callEditPhotoAlert()
    }
    
    // MARK: - UIAlertController
    
    private func callEditPhotoAlert() {
        func presentImagePicker(for sourceType: UIImagePickerControllerSourceType) {
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = sourceType
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
            else {
                //dismiss(animated: true, completion: nil)
            }
        }
        let alertController = UIAlertController(title: "Выбери изображение профиля", message: nil, preferredStyle: .alert)
        let galleryAction = UIAlertAction(title: "Установить из галлереи", style: .default) { action in
            presentImagePicker(for: .photoLibrary)
        }
        alertController.addAction(galleryAction)
        let cameraAction = UIAlertAction(title: "Сделать фото", style: .default) { action in
            presentImagePicker(for: .camera)
        }
        alertController.addAction(cameraAction)
        self.present(alertController, animated: true) { [weak self] in
            if let strongSelf = self {
                alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: strongSelf, action: #selector(strongSelf.alertControllerBackgroundTapped)))
            }
        }
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func leftButtonAction(_ sender: Any) {
        rightButton.isHidden ? self.inEditMode(true) : gcdSave()
    }
    
    @IBAction func rightButtonAction(_ sender: Any) {
        nsoSave()
    }
    
    private func write(_ image: UIImage, toURL url: URL) throws {
        let imageData = UIImagePNGRepresentation(image)!
        let archivedData = NSKeyedArchiver.archivedData(withRootObject: imageData)
        try archivedData.write(to: url, options: .atomic)
    }
    
    private func getImage(from url: URL) throws -> UIImage  {
        
        guard let imageData = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? Data else {
            
            throw NSError(domain: "", code: 1, userInfo: nil)
        }

        
        guard let image = UIImage(data: imageData) else {
            
            throw NSError(domain: "", code: 1, userInfo: nil)
        }
        
        return image
    }
    
    private func gcdSave() {
        leftButton.isEnabled = false
        rightButton.isEnabled = false
        do {
            try nameTextField.text?.write(to: storedNameURL, atomically: true, encoding: .utf8)
            try descriptionTextView.text.write(to: storedDescriptionURL, atomically: true, encoding: .utf8)
            try write(profileImage.image!, toURL: storedImageURL)
            print("saved!")
            
            let storedName = try String(contentsOf: storedNameURL)
            let storedDescription = try String(contentsOf: storedDescriptionURL)
            let storedImage = try getImage(from: storedImageURL)
            print("restored!")
        } catch {
            print("failed to save!")
        }
        self.inEditMode(false)
        leftButton.isEnabled = true
        rightButton.isEnabled = true
    }
    
//    private func saveToOneFile() {
//        do {
//            let nameData = nameTextField.text!.data(using: .utf8)
//            let descriptionData = descriptionTextView.text.data(using: .utf8)
//            let imageData = UIImagePNGRepresentation(profileImage.image!)
//            //let arr = [nameTextField.text!, descriptionTextView.text, imageData!] as [Any]
//            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            let filename = documentsDirectory.appendingPathComponent("profile-\(content.0)")
//            let isCreated = FileManager.default.fileExists(atPath: filename.absoluteString)
//            print(isCreated)
//
//
//            //            let lol = NSKeyedArchiver.archivedData(withRootObject: arr)
//            //            try lol.write(to: filename, options: .atomic)
//            let file = try FileHandle(forWritingTo: filename)
//
//            file.write(nameData!)
//
//            print(file.offsetInFile)
//
//            file.write(descriptionData!)
//            print(file.offsetInFile)
//
//            file.write(imageData!)
//            print(file.offsetInFile)
//
//            print("saved!")
//            //            let savedArr = NSArray(contentsOf: filename)
//            //            let savedName = savedArr?[0] as? String
//            //            print(savedName ?? "name")
//            //            let savedDescription = savedArr?[1] as? String!
//            //            print(savedDescription ?? "description")
//        } catch {
//            print("failed to save")
//        }
//    }
    
    private func nsoSave() {
        // type nso saving commands
        self.inEditMode(false)
    }
    
    private func inEditMode(_ flag: Bool) {
        let color = flag ? UIColor.black.cgColor : UIColor.white.cgColor
        bottomLine?.backgroundColor = color
        descriptionTextView.layer.borderColor = color
        descriptionTextView.isEditable = flag
        nameTextField.isEnabled = flag
        editPhotoButton.isHidden = !flag
        rightButton.isHidden = !flag
        leftButton.setTitle(flag ? "GCD" : "Редактировать", for: .normal)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}


// MARK: - UIImagePickerControllerDelegate

extension ProfileViewController: UIImagePickerControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImage.image = editedImage
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImage.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
}

