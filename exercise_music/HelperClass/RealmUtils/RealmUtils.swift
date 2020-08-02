//
//  RealmUtils.swift
//  AudioPlayer
//
//  Created by Adite Technologies on 19/07/18.
//  Copyright © 2018 Adite Technologies. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
import ObjectMapper

class RealmUtils: NSObject {
    
    static let sharedInstance = RealmUtils()
    
    
    func modelContainsCategory(item_id:String) -> DownloadObj?
    {
       let objects = Array(kRealm.objects(DownloadObj.self).filter("item_id=%@",item_id))
        if objects.count > 0
        {
            return objects[0]
        }
        return nil
    }
    
    func getDownloadObjects() -> [DownloadObj]
    {
       return Array(kRealm.objects(DownloadObj.self))
    }
    func getDownloadObjectIds() -> [Int]
    {
        return Array(kRealm.objects(DownloadObj.self).map( {Int($0.item_id ?? "0")})) as! [Int]
    }
    func getDistintCategoryFromDownload() -> [CategoryObj]
    {
        let cats = Set(kRealm.objects(DownloadObj.self).sorted(byKeyPath: "item_id", ascending: true).distinct(by: ["category_id"]))
        var catObjs:[CategoryObj] = []
        for cat in cats
        {
            let ob = CategoryObj(map: Map(mappingType: .fromJSON, JSON: [:]))
            ob?.category_name = cat.category_name
            catObjs.append(ob!)
        }
        return catObjs
    }
    
    func addDownloadObject(obj:DownloadObj)
    {
        try! kRealm.write {
            kRealm.add(obj, update: .all)
        }
    }
    func removeDownloadObject(itemId:String)
    {
        try! kRealm.write {
            kRealm.delete(kRealm.objects(DownloadObj.self).filter("item_id=%@",itemId))
        }
    }
}
