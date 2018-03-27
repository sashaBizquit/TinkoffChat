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
    private func gcdSave() {
        // type nso saving commands
        self.inEditMode(false)
    }
    
    private func nsoSave() {
        // type gcd saving commands
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

