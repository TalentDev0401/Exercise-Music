//
//  CategoryObj.swift
//  AudioPlayer
//
//  Created by Adite Technologies on 27/06/18.
//  Copyright © 2018 Adite Technologies. All rights reserved.
//

import UIKit
import ObjectMapper

class CategoryList: Mappable {
    
    var status: String?
    var msg: String?
    var data: [CategoryObj]?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    // Mappable
    func mapping(map: Map) {
        
        status                         <- map["status"]
        msg                            <- map["msg"]
        data                           <- map["data"]
    }
}
class CategoryObj: Mappable {
    
    var category_name: String?
    var items: [CategoryItem]?
        
    required init?(map: Map) {
        mapping(map: map)
    }
    // Mappable
    func mapping(map: Map) {
        category_name                         <- map["category_name"]
        items                           <- map["items"]
    }
}

class FavoriteObj: Mappable {
    var msg: String?
    var data: [CategoryItem]?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        msg                            <- map["msg"]
        data                           <- map["data"]
    }
}

class UpdateFavorite: Mappable {
    var status: String?
    var msg: String?
    var data: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        status                     <- map["status"]
        msg                        <- map["msg"]
        data                       <- map["data"]
    }
}

class CategoryItem: Mappable {
    var category_name: String?
    var item_id: String?
    var download_name: String?
    var item_name: String?
    var item_description: String?
    var item_file: String?
    var item_image: String?
    var video_url: String?
    var duration: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    // Mappable
    func mapping(map: Map) {
        category_name                         <- map["category_name"]
        item_id                           <- map["item_id"]
        download_name                         <- map["download_name"]
        item_name                           <- map["item_name"]
        item_description                         <- map["item_description"]
        item_file                           <- map["item_file"]
        item_image                         <- map["item_image"]
        video_url                           <- map["video_url"]
        duration                         <- map["duration"]
        
    }
}

class SessionId: Mappable {
    var status: String?
    var msg: String?
    var session_id: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        status                     <- map["status"]
        msg                        <- map["msg"]
        session_id                 <- map["session_id"]
    }
}

class StatsObj: Mappable {
    var total_exercise: Int?
    var total_duration: Float?
    var week_exercise: Int?
    var week_duration: Float?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        total_exercise                <- map["total_exercise"]
        total_duration                <- map["total_duration"]
        week_exercise                 <- map["week_exercise"]
        week_duration                 <- map["week_duration"]
    }
}
