//
//  NetworkManager.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 13.05.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import Foundation

protocol NetworkManagerProtocol: class {
    
    func askDataList(completionHandler: @escaping (_ data: Data?, _ error: Error?) -> Void)
    func askImageData(forPath path: String, completionHandler: @escaping (_ data: Data?, _ error: Error?) -> Void)
    
}

class NetworkManager: NetworkManagerProtocol {
    let session = URLSession.shared
    let apiKey = "8982277-c7cc329c5c96b35f52f1f1c30"
    var listUrl: URL?
    
    init() {
        let prefix = "https://pixabay.com/api/?key="
        let postfix = "&q=yellow+flowers&image_type=photo&pretty=true"
        let path = prefix + apiKey + postfix
        self.listUrl = URL(string: path)
    }
    
    func askDataList(completionHandler: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        guard let listURL = listUrl else {
            print("No list URL")
            return
        }
        
        dataTask(withURL: listURL, andCompletion: completionHandler)
    }
    
    func askImageData(forPath path: String, completionHandler: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        guard let imageURL = URL(string: path) else {
            print("Not an image URL: " + path)
            return
        }
        
        dataTask(withURL: imageURL, andCompletion: completionHandler)
    }
    
    private func dataTask(withURL url: URL, andCompletion completionHandler: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        let task = session.dataTask(with: url){ (data: Data?, response: URLResponse?, error: Error?) in
            completionHandler(data,error)
        }
        task.resume()
    }
}
