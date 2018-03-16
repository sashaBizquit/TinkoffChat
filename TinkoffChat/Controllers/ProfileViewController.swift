//
//  ViewController.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 21.02.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//
import Photos
import UIKit

class ProfileViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editProfileDescriptionButton: UIButton!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var profileDescription: UILabel!
    
    var content = ("Name","Description")
    
    override func viewDidLoad() {
        nameLabel.text = content.0
        profileDescription.text = content.1
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let cornerRadius = CGFloat.minimum(editPhotoButton.frame.width, editPhotoButton.frame.height) / 2.0
        profileImage.layer.cornerRadius = cornerRadius
        editPhotoButton.layer.cornerRadius = cornerRadius
        
        let inset = cornerRadius * (1.0 - 1.0/sqrt(2.0))
        editPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        
        editProfileDescriptionButton.layer.cornerRadius = editProfileDescriptionButton.frame.height / 4.0
        editProfileDescriptionButton.layer.borderColor = UIColor.black.cgColor
        editProfileDescriptionButton.layer.borderWidth = 1.5
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
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - UIImagePickerControllerDelegate

extension ProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImage.image = editedImage
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImage.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
}

