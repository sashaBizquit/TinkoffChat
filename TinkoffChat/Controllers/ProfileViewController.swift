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
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    private var dataManager: GCDDataManager!
    
    var id: UInt = 0
    private var bottomLine: CALayer?
    
    override func viewDidLoad() {
        
        dataManager = GCDDataManager(withId: id)
        dataManager.delegate = self
        
        nameTextField.delegate = self
        nameTextField.text = dataManager.profileName ?? GCDDataManager.defaultName //dataManager.getStoredName() /* (to do) */
        
        descriptionTextView.delegate = self
        descriptionTextView.text = dataManager.profileDescription ?? GCDDataManager.defaultDescription //dataManager.getStoredDescription() /* (to do) */
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.clear.cgColor
        
        if dataManager.profileImage != nil {
            dataManager.isImageChanged = false
        }
        
        profileImageView.image = dataManager.profileImage ?? GCDDataManager.defaultImage //dataManager.getStoredImage() /* (to do) */
        
        leftButton.layer.borderWidth = 1
        leftButton.setTitleColor(.gray, for: .disabled)
        leftButton.titleLabel?.text = "Редактировать"
        
        rightButton.isHidden = true
        rightButton.setTitleColor(.gray, for: .disabled)
        rightButton.layer.borderWidth = 1
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nameTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        descriptionTextView.endEditing(true)
        nameTextField.endEditing(true)
    }
    
    private func safeTrunc(of someString: String, offsetBy offset: Int) -> String {
        
        let safeOffset = min(offset,someString.count)
        let index = someString.index(someString.startIndex, offsetBy: safeOffset)
        return String(someString[..<index])
    }
    
    private func buttonsEnabled(equal to: Bool) {
        for button in [leftButton, rightButton] {
            button?.isEnabled = to
            button?.layer.borderColor = to ? UIColor.black.cgColor : UIColor.gray.cgColor
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = safeTrunc(of: textField.text!.condensedWhitespace, offsetBy: 25)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        buttonsEnabled(equal: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = safeTrunc(of: textView.text!, offsetBy: 300)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        buttonsEnabled(equal: true)
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
        profileImageView.layer.cornerRadius = imagesCornerRadius
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
        func presentImagePicker(by strongSelf: ProfileViewController, for sourceType: UIImagePickerControllerSourceType) {
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = strongSelf
                imagePicker.sourceType = sourceType
                imagePicker.allowsEditing = true
                strongSelf.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        let alertController = UIAlertController(title: "Выбери изображение профиля", message: nil, preferredStyle: .alert)
        let galleryAction = UIAlertAction(title: "Установить из галлереи", style: .default) { [weak self] action in
            if let strongSelf = self {
                presentImagePicker(by: strongSelf, for: .photoLibrary)
            }
        }
        alertController.addAction(galleryAction)
        let cameraAction = UIAlertAction(title: "Сделать фото", style: .default) { [weak self] action in
            if let strongSelf = self {
                presentImagePicker(by: strongSelf, for: .camera)
            }
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
        nameTextField.endEditing(false)
        descriptionTextView.endEditing(false)
        buttonsEnabled(equal: false)
        rightButton.isHidden ? self.inEditMode(true) : gcdSave()
    }
    
    @IBAction func rightButtonAction(_ sender: Any) {
        nameTextField.endEditing(false)
        descriptionTextView.endEditing(false)
        buttonsEnabled(equal: false)
        nsoSave()
    }
    
    private func gcdSave() {
        dataManager.save(nameTextField.text!, descriptionTextView.text!, profileImageView.image!)
        self.inEditMode(false)
        buttonsEnabled(equal: true)
    }
    
    private func nsoSave() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.view.addSubview(activityIndicator)
        activityIndicator.frame = self.view.bounds
        activityIndicator.startAnimating()
        
        let name, description: String?
        if nameTextField.text != dataManager.profileName {
            name = nameTextField.text
            dataManager.profileName = name
        }
        else {
            name = nil
        }
        if descriptionTextView.text != dataManager.profileDescription {
            description = descriptionTextView.text
            dataManager.profileDescription = description
        }
        else {
            description = nil
        }
        
        let saveOperation = OperationDataManager(withId: id,
                                                 name: name,
                                                 description: description,
                                                 image: profileImageView.image)

        saveOperation.delegate = self
        saveOperation.indicator = activityIndicator
        saveOperation.isImageChanged = dataManager.isImageChanged
        dataManager.isImageChanged = false
        dataManager.profileImage = profileImageView.image
        
        OperationQueue().addOperation(saveOperation)
        
        self.inEditMode(false)
        buttonsEnabled(equal: true)
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
            profileImageView.image = editedImage
            dataManager.isImageChanged = true
            buttonsEnabled(equal: true)
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.image = originalImage
            dataManager.isImageChanged = true
            buttonsEnabled(equal: true)
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - String

extension String {
    var condensedWhitespace: String {
        var newString = String()
        self.enumerateLines { line, _ in
            var elem = line.trimmingCharacters(in: .whitespaces)
            if !(elem.isEmpty) {
                elem = elem.components(separatedBy: .whitespacesAndNewlines).filter{!$0.isEmpty}.joined(separator: " ")
                newString.append(elem.appending("\n"))
            }
        }
        return newString.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
