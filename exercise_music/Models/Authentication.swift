//
//  Authentication.swift
//  exercise_music
//
//  Created by Billiard ball on 04.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class Signup: Mappable {
    
    var status: Int?
    var msg: String?
    var token: String?
    var user_id: String?
    var extra_time: String?
    var username: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    // Mappable
    func mapping(map: Map) {
        
        status                         <- map["status"]
        msg                            <- map["msg"]
        token                           <- map["token"]
        user_id                        <- map["user_id"]
        extra_time                     <- map["extra_time"]
        username                       <- map["username"]
    }
}
