//
//  DownloadCollectionViewController.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 13.05.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ImageCell"

protocol DownloadControllerProtocol: class {
    var indicator: UIActivityIndicatorView! {get}
    var collectionView: UICollectionView? {get}
    var completionHandler: ((UIImage) -> Void)? {get set}
}

class DownloadCollectionViewController: UICollectionViewController, DownloadControllerProtocol {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 3
    private var manager: DownloadManager?
    
    var completionHandler: ((UIImage) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = DownloadManager(withDelegate: self)
        self.collectionView?.dataSource = manager
        //self.collectionView
        self.indicator.startAnimating()
        self.title = "Выберите фото"
    }

    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return manager?.numberOfSections(in: collectionView) ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        manager?.collectionView(collectionView, didSelectItemAt: indexPath)
        self.dismiss(animated: true, completion: nil)
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return manager?.collectionView(collectionView,numberOfItemsInSection:section) ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return manager?.collectionView(collectionView,cellForItemAt:indexPath) ?? ImageCell()
    }
}

extension DownloadCollectionViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
