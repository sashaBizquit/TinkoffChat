//
//  ViewController.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 21.02.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //print("init: \(editButton.frame)") - связь outlet (в частности, editButton) ещё не подгрузились из storyboard
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad: \(editButton.frame)")
        
        let currentImage = #imageLiteral(resourceName: "slr-camera-2-xxl")
        let imageScale =  currentImage.size.width / 2
        let newSize = CGSize(width: imageScale, height: imageScale)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        currentImage.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        cameraIcon.image = newImage
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        cameraIcon.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped()
    {
       print("Выбери изображение профиля")
    }
    
    @IBAction func editAction(_ sender: Any) {
        let button = sender as? UIButton
        button?.titleLabel?.text = ""
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
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
        print("viewDidAppear: \(editButton.frame)") //
    }

}

