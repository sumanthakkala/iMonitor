//
//  FolderPath.swift
//  iMonitor
//
//  Created by Nirmal Sumanth on 27/02/20.
//  Copyright © 2020 Nirmal Sumanth. All rights reserved.
//

import Foundation

class FolderPath: NSObject{
    @objc dynamic var folderName: String
    @objc dynamic var folderPath: String
    
    init(path: String, name: String) {
        self.folderName = name
        self.folderPath = path
    }
}
