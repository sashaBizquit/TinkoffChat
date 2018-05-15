//
//  DownloadManager.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 13.05.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import Foundation


class DownloadManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let reuseIdentifier = "ImageCell"
    private var paths = [String]()
    private var images = [UIImage?]()
    var networkManager: NetworkManagerProtocol
    var parser: ParserManagerProtocol
    weak var delegate: DownloadControllerProtocol?
    
    init(withDelegate delegate: DownloadControllerProtocol) {
        networkManager = NetworkManager()
        parser = ParserManager()
        super.init()
        networkManager.askDataList {[weak self] data, error in
            guard let strongSelf = self else {
                assert(false, "weak DownloadManager became nil")
            }
            if let err = error {
                print(err.localizedDescription)
            }
            guard let strongData = data else {
                return
            }
            
            guard let pathsArray = strongSelf.parser.parsePhotoList(data: strongData) else {
                return
            }
            
            for path in pathsArray {
                strongSelf.paths.append(path)
                strongSelf.images.append(nil)
            }
            DispatchQueue.main.async { [weak strongSelf] in
                guard let strongSelf = strongSelf else {
                    assert(false, "weak DownloadManager became nil")
                }
                strongSelf.delegate?.indicator.stopAnimating()
                strongSelf.delegate?.collectionView?.reloadData()
            }
            
        }
        self.delegate = delegate
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return paths.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        guard let imageCell = cell as? ImageCell else {
            return cell
        }
        if (images.count > indexPath.row), images[indexPath.row] != nil {
            imageCell.imageView.image = images[indexPath.row]
        }
        else {
            imageCell.imageView.image = #imageLiteral(resourceName: "placeholder-user")
            if (paths.count > indexPath.row) {
                let path = self.paths[indexPath.row]
                networkManager.askImageData(forPath: path) {[weak self] data, error in
                    guard let strongSelf = self else {
                        assert(false, "weak DownloadManager became nil")
                    }
                    if let err = error {
                        print(err.localizedDescription)
                    }
                    guard let strongData = data else {
                        return
                    }
                    guard let image = UIImage(data: strongData) else {
                        print("Data is not an image for row #\(indexPath.row)")
                        return
                    }
                    
                    strongSelf.images[indexPath.row] = image
                    DispatchQueue.main.async { [weak strongSelf] in
                        guard let strongSelf = strongSelf else {
                            assert(false, "weak DownloadManager became nil")
                        }
                        strongSelf.delegate?.collectionView?.reloadItems(at: [indexPath])
                    }
                }
            }
        }
        
        return imageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let image = images[indexPath.row] {
            delegate?.completionHandler?(image)
        }
    }
    
}
