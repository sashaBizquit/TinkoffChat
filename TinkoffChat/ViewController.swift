//
//  ViewController.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 21.02.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//
import Photos
import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    private let cameraIconImage = #imageLiteral(resourceName: "slr-camera-2-xxl")
    
    // MARK: - UIViewController lifecycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // print("init: \(editButton.frame)")
        // editButton: connection between the outlet and storyboard object isn't established yet
        // storyboard isn't loaded at this moment
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad: \(editButton.frame)")
        // viewDidLoad: view is loaded and not yet put on a superview,
        // so it knows storyboard's frame (iPhone 5s) and doesn't know final frame (iPhone X)

        // cameraIcon menu provider
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        cameraIcon.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func editAction(_ sender: Any) {
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let cornerRadius = cameraIcon.frame.width / 2.0
        cameraIcon.layer.cornerRadius = cornerRadius
        profileImage.layer.cornerRadius = cornerRadius
        editButton.layer.cornerRadius = editButton.frame.height / 4.0
        editButton.layer.borderColor = UIColor.black.cgColor
        editButton.layer.borderWidth = 1.5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear: \(editButton.frame)")
        // viewDidAppear: view added to superview, frame changed to final state (iPhone X)
        
        // Adjusting camera icon according to circle borders
        let imageSize =  cameraIcon.frame.width / 2.0
        let newSize = CGSize(width: imageSize, height: imageSize)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        cameraIconImage.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        cameraIcon.image = newImage
    }
    
    // MARK: - UIAlertController
    
    @objc func imageTapped() {
        
        let alertController = UIAlertController(title: "Выбери изображение профиля", message: nil, preferredStyle: .alert)
        let galleryAction = UIAlertAction(title: "Установить из галлереи", style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let galleryImagePicker = UIImagePickerController()
                galleryImagePicker.delegate = self
                galleryImagePicker.sourceType = .photoLibrary
                galleryImagePicker.allowsEditing = true
                self.present(galleryImagePicker, animated: true, completion: nil)
            }
        }
        alertController.addAction(galleryAction)
        let cameraAction = UIAlertAction(title: "Сделать фото", style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let cameraImagePicker = UIImagePickerController()
                cameraImagePicker.delegate = self
                cameraImagePicker.sourceType = .camera
                cameraImagePicker.allowsEditing = false
                self.present(cameraImagePicker, animated: true, completion: nil)
            }
        }
        alertController.addAction(cameraAction)
        self.present(alertController, animated: true, completion: nil)
    }
}


// MARK: -
extension ViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImage.image = image
        }
        else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

