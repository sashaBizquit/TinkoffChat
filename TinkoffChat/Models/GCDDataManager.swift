//
//  GCDDataManager.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 28.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import Foundation

class GCDDataManager {
    var name: String!
    var description: String!
    var image: UIImage!
    
    init() {
        name = String()
        description = String()
        image = UIImage()
    }
    
    init(withName newName: String, description newDescription: String, image newImage: UIImage) {
        name = newName
        description = newDescription
        image = newImage
    }
    
    func save(name: String, description: String, image: UIImage) {
//        do {
//            try name.write(to: storedNameURL, atomically: true, encoding: .utf8)
//            try description.write(to: storedDescriptionURL, atomically: true, encoding: .utf8)
//            try write(profileImage.image!, toURL: storedImageURL)
//            print("saved!")
//
//            let storedName = try String(contentsOf: storedNameURL)
//            let storedDescription = try String(contentsOf: storedDescriptionURL)
//            let storedImage = try getImage(from: storedImageURL)
//            print("restored!")
//        } catch {
//            print("failed to save!")
//        }
    }
        
    private func saveName(_ newName: String) {
        if self.name == newName { return }
        
    }
    
}

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
