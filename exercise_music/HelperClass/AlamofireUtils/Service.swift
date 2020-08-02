//
//  Service.swift
//  Util_Classes
//
//  Created by Adite Technologies on 13/09/17.
//  Copyright © 2017 Adite Technologies. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import ObjectMapper

//let configuration1 = URLSessionConfiguration.background(withIdentifier: "background")
//var manager = Alamofire.SessionManager()
//manager = Alamofire.SessionManager(configuration: configuration1)
//manager.startRequestsImmediately = true
protocol ServiceDelegate
{
    func onFault(resultData:[String:Any]?)
    func onResult(resultData:Any?)
}
public class Service
{
    var receivedData:[String:Any]?
    var receivedArray:NSArray?
    var delegate: ServiceDelegate?
    var apiName:String?
    var searchRequest : DataRequest?
    
    func checkInternetStatus() -> Bool
    {
        return Reachability.isConnectedToNetwork();
    }
    func getTopMostController() -> UIViewController
    {
        var topController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topController?.presentedViewController
        {
            topController = presentedViewController
        }
        // topController should now be your topmost view controller
        return topController!
    }
    //MARK:- Song Downloads -
     func downloadAudioFiles(obj:DownloadObj,downloaded:Bool,completion: @escaping (_ sts: Bool) -> ())
    {
        if !downloaded {
            let imgFileName = URL(string:obj.item_image_path!)
            let imgName = imgFileName?.lastPathComponent
            
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                documentsURL.appendPathComponent("ImageFiles")
                documentsURL.appendPathComponent(imgName!)
                return (documentsURL, [.createIntermediateDirectories])
            }
          
            doAlamoFire.sharedInstance.sessionManagerBackground.download(obj.item_image_path!, to: destination).response { response in
                if let _ = response.destinationURL?.path {
                    obj.item_image_path = "/ImageFiles/" + imgName!
                    
                    if let _:DownloadObj = RealmUtils.sharedInstance.modelContainsCategory(item_id: obj.item_id!)
                    {
                        
                        self.setRealmData(obj: obj, completion: { (str) in
                            obj.item_file_path = Directory.AudioFiles + str
                                                     
                            if jukebox != nil && kAppDelegate.isFromDownload {
                                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                
                                jukebox.append(item: JukeboxItem(URL: documentsURL.appendingPathComponent(Directory.AudioFiles).appendingPathComponent(str), localID1: obj.item_id!, localTitle: obj.item_name!, localDesc: obj.item_description!, imgURL: documentsURL.path + obj.item_image_path!,downloadName1:obj.download_name,lyrics1 : nil), loadingAssets: false)
                            }
                            RealmUtils.sharedInstance.addDownloadObject(obj: obj)
                            completion(true)
                        })
                    } else {
                        self.setRealmData(obj: obj, completion: { (str) in
                            obj.item_file_path = "\(Directory.AudioFiles)" + str
                         //   helperOb.toast(ToastMsg.DownlodedSuccess)
                            
                            if jukebox != nil && kAppDelegate.isFromDownload
                            {
                                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                
                                jukebox.append(item: JukeboxItem(URL: documentsURL.appendingPathComponent(Directory.AudioFiles).appendingPathComponent(str), localID1: obj.item_id!, localTitle: obj.item_name!, localDesc: obj.item_description!, imgURL: documentsURL.path + obj.item_image_path!,downloadName1:obj.download_name,lyrics1: nil), loadingAssets: false)
                            }
                            RealmUtils.sharedInstance.addDownloadObject(obj: obj)
                            completion(true)
                        })
                    }
                }
            }
        }
    }
     func downloadCategoryImgs(obj:DownloadObj,downloaded:Bool,completion: @escaping (_ str: String) -> ())
    {
        
//       // let catFileName = URL(string:obj.category_image_path!)
//        let cateImgName = URL(string:obj.category_image_path!)?.lastPathComponent
//        // let pathExtension = "." + (catFileName?.pathExtension)!
//        
//        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
//            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            documentsURL.appendPathComponent(Directory.CategoryImages)
//            documentsURL.appendPathComponent(cateImgName!)
//            return (documentsURL, [.createIntermediateDirectories])
//        }
//        
//        doAlamoFire.sharedInstance.sessionManagerBackground.download(obj.category_image_path!, to: destination).response() { response in
//            
//            if let _ = response.destinationURL?.path {
//                completion("/" + cateImgName!)
//            }
//        }
    }
     func setRealmData(obj:DownloadObj,completion: @escaping (_ filePath: String) -> ())
    {
        let audioFileName = URL(string:obj.item_file_path!)
        let pathExtension = "." + (audioFileName?.pathExtension)!
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent(Directory.AudioFiles)
            documentsURL.appendPathComponent(obj.download_name! + pathExtension)
            return (documentsURL, [.createIntermediateDirectories])
        }
        doAlamoFire.sharedInstance.sessionManagerBackground.download(obj.item_file_path!, to: destination).downloadProgress(queue: .main, closure: {
            (progress) in
            let dict:[String:Any] = ["progress":Float(progress.fractionCompleted),"songID":obj.item_id!]
              NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.ProgressSong), object: nil, userInfo: dict)

        }).response { response in
            let dict:[String:Any] = ["songID":obj.item_id!]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.ProgressSongCompleted), object: nil, userInfo: dict)
            if (response.destinationURL?.path) != nil {
                completion("/" + obj.download_name! + pathExtension)
            }
        }
    }
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
    
    //MARK: PUT 
    func callPutURL(url:URL,parameters:[String:Any]?,encodingType:String,headers:[String : String]!) -> Void
    {
        // post request and response json(with default options)
        if self.checkInternetStatus()
        {
            doAlamoFire.sharedInstance.upload(multipartFormData: { multipartFormData in
                if encodingType.isEqual("default")
                {
                    for (key,value) in parameters! {
                        multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                    }
                }
                else
                {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: "", options: JSONSerialization.WritingOptions.prettyPrinted)
                        multipartFormData.append(data, withName: "json key name", mimeType: "application/json")
                    } catch let myJSONError {
                        print(myJSONError)
                    }
                }},
                                              to: url,
                                              method:.put,
                                              headers:headers,
                                              encodingCompletion: { encodingResult in
                                                switch encodingResult {
                                                case .success(let upload, _, _):
                                                    upload.validate().responseJSON
                                                        { response in
                                                            switch response.result
                                                            {
                                                            case .success:
                                                                if let status = response.response?.statusCode
                                                                {
                                                                    switch(status)
                                                                    {
                                                                    case 200:
                                                                        print(response.result.value as Any)
                                                                        self.receivedData = response.result.value as! [String : Any]?
                                                                        self.delegate?.onResult(resultData: self.receivedData!)
                                                                        break
                                                                    default:
                                                                        let dict:NSDictionary = (response.result.value as! NSDictionary?)!
                                                                        self.receivedData = dict.object(forKey: "error") as! [String : Any]?
                                                                        self.delegate?.onFault(resultData: self.receivedData!)
                                                                        break
                                                                    }
                                                                }
                                                                break
                                                            case .failure(let error):
                                                                Utils.HideAllHud()
                                                                print("update failed",error.localizedDescription)
                                                                self.delegate?.onFault(resultData: nil)
                                                                break
                                                            }
                                                    }
                                                    break
                                                    
                                                case .failure(let error):
                                                    Utils.HideAllHud()
                                                    print("update failed",error.localizedDescription)
                                                    self.delegate?.onFault(resultData: nil)
                                                    break
                                                }
            })
        }
        else
        {
            Utils.HideAllHud()
            let alert = UIAlertController(title: "No Internet", message: "\(Alerts.NoInternet)", preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default)
            { (alert) in
                
              //  self.callPutURL(url: url, parameters: parameters, encodingType: encodingType,headers: headers)
            }
            alert.addAction(retryAction)
            presetAlertController(controller:alert)
        }
    }
    
    //MARK: DELETE 
    func callDeleteURL(url:URL,parameters:[String:Any],encodingType:String,headers:[String : String]!) -> Void {
        if self.checkInternetStatus()
        {
            doAlamoFire.sharedInstance.upload(multipartFormData: { multipartFormData in
                if encodingType.isEqual("default")
                {
                    for (key,value) in parameters {
                        multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                    }
                }
                else
                {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: "", options: JSONSerialization.WritingOptions.prettyPrinted)
                        multipartFormData.append(data, withName: "json key name", mimeType: "application/json")
                    } catch let myJSONError {
                        print(myJSONError)
                    }
                }},
                   to: url,method:.delete, headers:headers, encodingCompletion: { encodingResult in
                            switch encodingResult {
                case .success(let upload, _, _):
                    upload.validate().responseJSON
                        { response in
                            switch response.result
                            {
                            case .success:
                                if let status = response.response?.statusCode
                                {
                                    switch(status)
                                    {
                                    case 200:
                                        print(response.result.value as Any)
                                        self.receivedData = response.result.value as! [String : Any]?
                                        self.delegate?.onResult(resultData: self.receivedData ?? nil)
                                        break
                                    default:
                                        let dict:NSDictionary = (response.result.value as! NSDictionary?)!
                                        self.receivedData = dict.object(forKey: "error") as! [String : Any]?
                                        self.delegate?.onFault(resultData: self.receivedData!)
                                        break
                                    }
                                }
                                break
                            case .failure(let error):
                                Utils.HideAllHud()
                                print("Delete failed",error.localizedDescription)
                                break
                            }
                    }
                    break
                    
                case .failure(let error):
                    Utils.HideAllHud()
                    print("Delete failed",error.localizedDescription)
                    break
                }
            })
        }
        else{
            Utils.HideAllHud()
            let alert = UIAlertController(title: "No Internet", message: "\(Alerts.NoInternet)", preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default)
            { (alert) in
                
            //   self.callDeleteURL(url: url, parameters: parameters, encodingType:encodingType,headers: headers)
            }
            alert.addAction(retryAction)
            presetAlertController(controller:alert)
        }
        
    }
    //MARK: GET 
    func callGetURL(url:URL,parameters:[String:Any]?,encodingType:String,headers:[String : String]?) -> Void {
        
        if self.checkInternetStatus()
        {
            //   Utils.Show()
            if encodingType .isEqual("default")
            {
                doAlamoFire.sharedInstance.request(url, method: .get, parameters: parameters, encoding:JSONEncoding.default, headers: headers)
                    .responseJSON { response in
                        
                        switch response.result
                        {
                        case .success:
                            if let status = response.response?.statusCode
                            {
                                switch(status)
                                {
                                case 200:
                                    if let signupResponse = response.result.value
                                    {
                                        self.delegate?.onResult(resultData: signupResponse)
                                    }
                                default:
                                    let dict:NSDictionary = (response.result.value as! NSDictionary?)!
                                    self.receivedData = dict.object(forKey: "error") as! [String : Any]?
                                    self.delegate?.onFault(resultData: self.receivedData!)
                                }
                            }
                            break
                        case .failure(let error):
                            Utils.HideAllHud()
                            self.delegate?.onFault(resultData: nil)
                            print(error)
                            break
                        }
                }
            }
            else{
                doAlamoFire.sharedInstance.request(url, method: .get, parameters: parameters, encoding:JSONEncoding.default, headers: headers)
                    .responseJSON { response in
                        
                        if let status = response.response?.statusCode
                        {
                            switch(status){
                                
                            case 200:
                                self.receivedData = response.result.value as! [String : Any]?
                                self.delegate?.onResult(resultData: self.receivedData!)
                            default:
                                let dict:NSDictionary = (response.result.value as! NSDictionary?)!
                                self.receivedData = dict.object(forKey: "error") as! [String : Any]?
                                self.delegate?.onFault(resultData: self.receivedData!)
                            }
                        }
                }
            }
        }
        else
        {
            Utils.HideAllHud()
            let alert = UIAlertController(title: "No Internet", message: "\(Alerts.NoInternet)", preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default)
            { (alert) in
                
              //  self.callGetURL(url: url, parameters: parameters, encodingType: encodingType,headers: headers)
            }
            alert.addAction(retryAction)
            presetAlertController(controller:alert)
        }
    }

    //MARK: POST 
    func callPostURL(url:URL,parameters:[String:Any]?,encodingType:String,headers:[String : String]?) -> Void
    {
        if self.checkInternetStatus()
        {
            // Utils.Show()
            if encodingType .isEqual("default")
            {
                doAlamoFire.sharedInstance.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                    .responseJSON { response in
                        
                        switch response.result {
                            
                        case .success:
                            
                            if let status = response.response?.statusCode
                            {
                                switch(status){
                                    
                                case 200:
                                    if let signupResponse = response.result.value
                                    {
                                        self.delegate?.onResult(resultData: signupResponse)
                                    }
                                    break
                                default:
                                    
                                    let dict:NSDictionary = (response.result.value as! NSDictionary?)!
                                    self.receivedData = dict.object(forKey: "error") as! [String : Any]?
                                    self.delegate?.onFault(resultData: self.receivedData!)
                                    break
                                }
                            }
                            break
                        case .failure(let error):
                            Utils.HideAllHud()
                            self.delegate?.onFault(resultData: nil)
                            print(error)
                            break
                        }
                }
            }
            else{
                doAlamoFire.sharedInstance.request(url, method: .post, parameters: parameters, encoding:JSONEncoding.default, headers: headers)
                    .responseJSON { response in
                        
                        if let status = response.response?.statusCode
                        {
                            switch(status){
                            case 200:
                                self.receivedData = response.result.value as! [String : Any]?
                                self.delegate?.onResult(resultData: self.receivedData!)
                            default:
                                let dict:NSDictionary = (response.result.value as! NSDictionary?)!
                                self.receivedData = dict.object(forKey: "error") as! [String : Any]?
                                self.delegate?.onFault(resultData: self.receivedData!)
                            }
                        }
                }
            }
        }
        else{
            Utils.HideAllHud()
            let alert = UIAlertController(title: "No Internet", message: "P\(Alerts.NoInternet)", preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default)
            { (alert) in
                
              //  self.callPostURL(url: url, parameters: parameters, encodingType: encodingType,headers: headers)
            }
            alert.addAction(retryAction)
            presetAlertController(controller:alert)
        }
    }
    ///call sts api
    func callStsPostURL(url:URL,parameters:[String:Any],encodingType:String,headers:[String : String]?) -> Void
    {
        if self.checkInternetStatus()
        {
            // Utils.Show()
            if encodingType .isEqual("default")
            {
               
                doAlamoFire.sharedInstance.request(url, method: .post, parameters: parameters, encoding:URLEncoding.default, headers: headers)
                    .responseJSON { response in
                        
                        switch response.result {
                            
                        case .success:
                            
                            if let status = response.response?.statusCode
                            {
                                switch(status){
                                    
                                case 200:
                                    if let signupResponse = response.result.value
                                    {
                                        self.delegate?.onResult(resultData: signupResponse)
                                    }
                                    break
                                default:
                                    
                                    let dict:NSDictionary = (response.result.value as! NSDictionary?)!
                                    self.receivedData = dict.object(forKey: "error") as! [String : Any]?
                                    self.delegate?.onFault(resultData: self.receivedData!)
                                    break
                                }
                            }
                            break
                        case .failure(let error):
                            Utils.HideAllHud()
                            self.delegate?.onFault(resultData: nil)
                            print(error)
                            break
                        }
                }
            }
            else{
                doAlamoFire.sharedInstance.request(url, method: .post, parameters: parameters, encoding:JSONEncoding.default, headers: headers)
                    .responseJSON { response in
                        
                        if let status = response.response?.statusCode
                        {
                            switch(status){
                            case 200:
                                self.receivedData = response.result.value as! [String : Any]?
                                self.delegate?.onResult(resultData: self.receivedData!)
                            default:
                                let dict:NSDictionary = (response.result.value as! NSDictionary?)!
                                self.receivedData = dict.object(forKey: "error") as! [String : Any]?
                                self.delegate?.onFault(resultData: self.receivedData!)
                            }
                        }
                }
            }
        }
    }

    //MARK: DownloadImage 
    func downloadImage(url:String,savedImageName:String,completion: @escaping (_ filePath: URL) -> ())
    {
        if self.checkInternetStatus()
        {
            //   Utils.Show()
            Alamofire.request(url).responseImage { response in
                if let image = response.result.value {
                    if let data = image.pngData() {
                        let filename = self.getDocumentsDirectory().appendingPathComponent("ImageFiles").appendingPathComponent(savedImageName)
                         print("filename \(filename)")
                        try? data.write(to: filename)
                            completion(filename)
                    }
                }
            }
        }
        else{
            Utils.HideAllHud()
            let alert = UIAlertController(title: "No Internet", message: "\(Alerts.NoInternet)", preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default)
            { (alert) in
                
               // self.downloadImage(url:url,savedImageName:savedImageName, completion: completion)
            }
            alert.addAction(retryAction)
            presetAlertController(controller:alert)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDirectory = paths[0]
        
        return docDirectory
    }

    func presetAlertController(controller:UIAlertController)
    {
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
            rootViewController?.present(controller, animated: true, completion: nil)
        }
        else
        {
            rootViewController?.presentedViewController?.present(controller, animated: true, completion: nil)
        }
    }
}

