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
    @IBOutlet weak var editProfileInfoButton: UIButton!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet var descriptionTextView: UITextView!
    
    @IBOutlet var nameTextField: UITextField!
    var content = ("Name","Description")
    private var bottomLine: CALayer?
    override func viewDidLoad() {
        
        editPhotoButton.isHidden = true
        
        nameTextField.isEnabled = false
        nameTextField.delegate = self
        nameTextField.text = content.0
        
        descriptionTextView.isEditable = false
        descriptionTextView.delegate = self
        descriptionTextView.text = content.1
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.borderColor = UIColor.clear.cgColor
        
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
    
//    func textViewDidEndEditing(_ textView: UITextView) {
//        textView.layer.borderColor = UIColor.clear.cgColor
//    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        print("nu privet")
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
        bottomLine?.backgroundColor = UIColor.black.cgColor
        
        
        let cornerRadius = CGFloat.minimum(editPhotoButton.frame.width, editPhotoButton.frame.height) / 2.0
        profileImage.layer.cornerRadius = cornerRadius
        editPhotoButton.layer.cornerRadius = cornerRadius
        
        let inset = cornerRadius * (1.0 - 1.0/sqrt(2.0))
        editPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        
        editProfileInfoButton.layer.cornerRadius = editProfileInfoButton.frame.height / 4.0
        editProfileInfoButton.layer.borderColor = UIColor.black.cgColor
        editProfileInfoButton.layer.borderWidth = 1.5
        
        descriptionTextView.layer.cornerRadius = editProfileInfoButton.layer.cornerRadius
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
    @IBAction func editProfileInfo(_ sender: UIButton) {
        self.enterEditMode()
    }
    
    private func enterEditMode() {
        nameTextField.layer.addSublayer(bottomLine!)
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        descriptionTextView.isEditable = true
        nameTextField.isEnabled = true
        editPhotoButton.isHidden = false
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

