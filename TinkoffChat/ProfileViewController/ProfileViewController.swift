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
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    
    private var dataManager: DataManager!
    
    var id: UInt = 0
    private var bottomLine: CALayer?
    
    override func viewDidLoad() {
        
        dataManager = DataManager(withId: id)
        dataManager.delegate = self
        
        nameTextField.delegate = self
        nameTextField.text = dataManager.getStoredName()
        
        infoTextView.delegate = self
        infoTextView.text = dataManager.getStoredDescription()
        infoTextView.layer.borderWidth = 1
        infoTextView.layer.borderColor = UIColor.clear.cgColor
        
        photoImageView.image = dataManager.getStoredImage()
        
        editButton.layer.borderWidth = 1
        editButton.setTitleColor(.gray, for: .disabled)
        editButton.titleLabel?.text = "Редактировать"

        bottomLine = CALayer()
        bottomLine?.frame = CGRect(x: 0.0, y: nameTextField.frame.height - 1, width: nameTextField.frame.width, height: 1.0)
        nameTextField.layer.addSublayer(bottomLine!)
        
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
        infoTextView.endEditing(true)
        nameTextField.endEditing(true)
    }
    
    private func safeTrunc(of someString: String, offsetBy offset: Int) -> String {
        let safeOffset = min(offset,someString.count)
        let index = someString.index(someString.startIndex, offsetBy: safeOffset)
        return String(someString[..<index])
    }
    
    private func buttonsEnabled(equal to: Bool) {
        editButton?.isEnabled = to
        editButton?.layer.borderColor = to ? UIColor.black.cgColor : UIColor.gray.cgColor
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
        guard let keyboardFrame = sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardHeight: CGFloat
        if #available(iOS 11.0, *) {
            keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
        } else {
            keyboardHeight =  keyboardFrame.cgRectValue.height
        }
        
        self.view.frame.origin.y = -1.0 * keyboardHeight
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let imagesCornerRadius = CGFloat.minimum(editPhotoButton.frame.width, editPhotoButton.frame.height) / 2.0
        photoImageView.layer.cornerRadius = imagesCornerRadius
        editPhotoButton.layer.cornerRadius = imagesCornerRadius
        
        let inset = imagesCornerRadius * (1.0 - 1.0/sqrt(2.0))
        editPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        
        let buttonsCornerRadius = editButton.frame.height / 4.0
        infoTextView.layer.cornerRadius = buttonsCornerRadius
        
        editButton.layer.cornerRadius = buttonsCornerRadius
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
        infoTextView.endEditing(false)
        buttonsEnabled(equal: false)
        editPhotoButton.isHidden ? self.inEditMode(true) : gcdSave()
    }
    
    private func gcdSave() {
        dataManager.save(nameTextField.text!, infoTextView.text!, photoImageView.image!)
        inEditMode(false)
        buttonsEnabled(equal: true)
    }
    
    private func inEditMode(_ flag: Bool) {
        let color = flag ? UIColor.black.cgColor : UIColor.white.cgColor
        bottomLine?.backgroundColor = color
        infoTextView.layer.borderColor = color
        infoTextView.isEditable = flag
        nameTextField.isEnabled = flag
        editPhotoButton.isHidden = !flag
        editButton.setTitle(flag ? "Сохранить" : "Редактировать", for: .normal)
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
            photoImageView.image = editedImage
            dataManager.isImageChanged = true
            buttonsEnabled(equal: true)
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photoImageView.image = originalImage
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
