//
//  ParserManager.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 13.05.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import Foundation

//import

protocol ParserManagerProtocol: class {
    func parsePhotoList(data: Data) -> [String]?
}

class ParserManager: ParserManagerProtocol {
    func parsePhotoList(data: Data) -> [String]? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            print("No json in came list")
            return nil
        }
        
        guard let dictionary = json as? Dictionary<String, Any?> else {
            print("JSON is not a dictionary")
            return nil
        }
        
        guard let hits = dictionary["hits"] as? Array<Dictionary<String, Any?>> else {
            print("Dictionary has no [hits]")
            return nil
        }

        var parsedData = [String]()
        for (index,dict) in hits.enumerated() {
            guard let link = dict["largeImageURL"] as? String else {
                print("no [largeImageURL] member in [hits][\(index)]")
                continue
            }
            parsedData.append(link)
        }
        return parsedData
    }
}
