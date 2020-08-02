//
//  DownloadObj.swift
//  AudioPlayer
//
//  Created by Adite Technologies on 04/07/18.
//  Copyright © 2018 Adite Technologies. All rights reserved.
//

import UIKit
import Foundation
import ObjectMapper
import RealmSwift
import Realm

class DownloadObj: Object,Mappable {
 
    @objc dynamic var item_id: String?
    @objc dynamic var item_name: String?
    @objc dynamic var item_description: String?
    @objc dynamic var item_file_path: String?
    @objc dynamic var download_name: String?
    @objc dynamic var item_image_path: String?
    @objc dynamic var category_name: String?
           
    required convenience init?(map: Map)
    {
        self.init()
    }
    override static func primaryKey() -> String? {
        return "item_id"
    }
    // Mappable
    func mapping(map: Map) {
        item_id                          <- map["item_id"]
        item_name                        <- map["item_name"]
        item_description                 <- map["item_description"]
        item_file_path                   <- map["item_file_path"]
        download_name                    <- map["download_name"]
        item_image_path                  <- map["item_image_path"]
        category_name                    <- map["category_name"]
    }
}
