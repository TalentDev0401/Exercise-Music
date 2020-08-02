//
//  JukeBoxUtils.swift
//  AudioPlayer
//
//  Created by Adite Technologies on 28/06/18.
//  Copyright © 2018 Adite Technologies. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

@objc
class JukeBoxUtils: NSObject,JukeboxDelegate
{
    //MARK:- Variables
    
    @objc static let sharedInstance = JukeBoxUtils()
    var items1 : [JukeboxItem]! = []
    var subCategoryList : [FavoriteObj]! = []
    var downloadList : [DownloadObj]! = []
    var subCategoryFileItems : [JukeboxItem]! = []
    let service = Service()
    var playToEnd = false
    // MARK:- Custom Methods -
    func configure(items: [JukeboxItem]) -> () {
        Utils.removeUserInfoObject()
        jukebox = Jukebox(delegate: self, items:items)
        userDefault.set(kAppDelegate.isFromDownload, forKey: "jukebox_download")
        userDefault.set(kAppDelegate.isFromFavorite, forKey: "jukebox_favorite")
        userDefault.synchronize()
        Utils.setUserInfoObject(jukebox)
    }
    func configureBox(items: [JukeboxItem]) -> () {
        kAppDelegate.isFromDownload = userDefault.bool(forKey: "jukebox_download")
        kAppDelegate.isFromFavorite = userDefault.bool(forKey: "jukebox_favorite")
        
        if kAppDelegate.isFromDownload
        {
            self.downloadList = RealmUtils.sharedInstance.getDownloadObjects()
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            items1 = []
            for ob in self.downloadList
            {
                let audioStr = Directory.AudioFiles
                let token = (ob.item_file_path!).components(separatedBy: audioStr)
             //   print("token \(token)")
                let audioUrl = (ob.item_file_path!).replacingOccurrences(of: token[0], with: "")
                let audioUrl11 = documentsURL.appendingPathComponent(audioUrl)
                
                let audioStr1 = "/\(Directory.ImageFiles)"
                let token1 = (ob.item_image_path!).components(separatedBy: audioStr1)
             //   print("token \(token1)")
                let audioUrl2 = (ob.item_image_path!).replacingOccurrences(of: token1[0], with: "")
                let audioUrl22 = documentsURL.appendingPathComponent(audioUrl2)
                
                items1.append(JukeboxItem(URL: audioUrl11, localID1:ob.item_id!,localTitle: ob.item_name!, localDesc: ob.item_description!, imgURL: audioUrl22.path,downloadName1:ob.download_name,lyrics1 : nil))
            }
            jukebox = Jukebox(delegate: self, items:items1)
        }
        else if kAppDelegate.isFromFavorite
        {
            if Reachability.isConnectedToNetwork()
            {
//                self.subCategoryList = RealmUtils.sharedInstance.getFavoriteObjects()
                self.subCategoryFileItems.removeAll()
//                for  ob in self.subCategoryList
//                {
//                self.subCategoryFileItems.append(JukeboxItem(URL:URL(string:ob.item_file!)!,localID1:ob.item_id, localTitle: ob.item_name, localDesc:  ob.item_description, imgURL: ob.item_image!,downloadName1:ob.download_name,category_image_path :ob.category_image_path,category_id: ob.category_id,category_name : ob.category_name,lyrics1 : ob.lyrics))
//                }
                 jukebox = Jukebox(delegate: self, items:self.subCategoryFileItems)
            }
            else
            {
                jukebox = Jukebox.init()
                kAppDelegate.isFromFavorite = false
            }
        }
        else
        {
            jukebox = Jukebox(delegate: self, items:items)
            kAppDelegate.isFromSearch = true
        }
         self.play(index: userDefault.integer(forKey: "jukebox_play_index"))
    }
    
    func volumeSliderValueChanged() {
//        if let jk = jukebox {
//           // jk.volume = volumeSlider.value
//        }
    }
    @objc func progressSliderValueChanged(value:Double) {
       if let duration = jukebox.currentItem?.meta.duration {
          jukebox.seek(toSecond: Int(Double(value) * duration))
       }
    }
    func prevAction() {
        jukebox.repeatcount = 0
        if  jukebox.playIndex == 0 {
            print("jukebox.playIndex \(jukebox.playIndex)")
            print("jukebox.queuedItems.count \(jukebox.queuedItems.count)")
          //  jukebox.replayCurrentItem()
            //changed by ...PC
            if jukebox.queuedItems.count == 1
            {
                jukebox.replayCurrentItem()
            }
            else
            {
                    play(index:jukebox.queuedItems.count - 1)
            }
        }
        else
        {
            jukebox.playPrevious()
        }
    }
     func nextAction() {
        jukebox.repeatcount = 0
        if jukebox.playIndex == 0 && jukebox.queuedItems.count == 1
        {
            //changed by ...PC
            jukebox.replayCurrentItem()
        }
        else if jukebox.playIndex >= jukebox.queuedItems.count - 1
        {
            jukebox.play(atIndex: 0)
        }
        else
        {
            jukebox.playNext()
        }
    }
     func playPauseAction(index:Int) {
        switch jukebox.state {
        case .ready :
            self.play(index: index)
        case .playing :
            jukebox.pause()
        case .paused :
            jukebox.play()
        default:
            jukebox.stop()
        }
    }
      @objc func playPauseAction() {
            switch jukebox.state {
            case .ready :
                jukebox.play(atIndex: 0)
            case .playing :
                jukebox.pause()
            case .paused :
                jukebox.play()
            default:
                jukebox.stop()
            }
        }
    func play(index:Int!) {
        
        if jukebox != nil
        {
            jukebox.stop()
        }
        jukebox.play(atIndex: index)
    }
    func replayAction() {
        jukebox.replay()
    }
     func stopAction() {
        if jukebox != nil
        {
            jukebox.stop()
        }
    }
    func callDownloadStsAPI(itemId:String)
    {
        var data = [String: Any]()
        data[String(AppParams.item_id)] = itemId
        data[String(AppParams.FLAG)] = 1  //0 = download and 1 = listen
        self.service.callStsPostURL(url: URL(string : AppURL.API_POST_UPDATE_SONG_STATUS)!, parameters: data, encodingType: "default", headers: nil)
    }
    func resetJukebox()
    {
        if jukebox != nil
        {
            jukebox.invalidatePlayback()
            jukebox.repeatOn = false
            jukebox.shuffleOn = false
            jukebox.repeatcount = 0
        }
        kAppDelegate.repeteCount = 0
        kAppDelegate.radioTitle = ""
        kAppDelegate.textFieldRepeteValue = ""
        kAppDelegate.fromWhereRepeate = ""
        kAppDelegate.duration = 0.00
        kAppDelegate.currentTime = 0.00
    }
}
// MARK:- JukeboxDelegate -
extension JukeBoxUtils
{
    func jukeboxDidLoadItem(_ jukebox: Jukebox, item: JukeboxItem) {
    }
    func jukeboxPlaybackProgressDidChange(_ jukebox: Jukebox) {
        
        if let currentTime = jukebox.currentItem?.currentTime, let duration = jukebox.currentItem?.meta.duration {
            
            kAppDelegate.currentTime = Double(Utils.milliSecondsToTimer(milliseconds: Int(currentTime * 1000)))!
             kAppDelegate.duration = Double(Utils.milliSecondsToTimer(milliseconds: Int(duration * 1000)))!
            if duration >= currentTime
            {
                kAppDelegate.leftDuration = Double(Utils.milliSecondsToTimer(milliseconds: Int(duration * 1000) - Int(currentTime * 1000)))!
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.PlaybackProgressChange), object: nil, userInfo: nil)
        
            if Int(currentTime) == Int(duration) && !playToEnd
            {
                playToEnd = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.PlaybackEnded), object: nil, userInfo: nil)                
           }
            else if currentTime > 0.0 && kAppDelegate.duration != 0.0
            {
                playToEnd = false
                if String(format: "%.2f",kAppDelegate.currentTime) == "0.02"
                {
                    //self.callDownloadStsAPI(itemId: (jukebox.currentItem?.localId)!)
                }
            }
            else
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.PlaybackInfoChange), object: nil, userInfo: nil)
            }
        } else {
            //  resetUI()
        }
    }

    func jukeboxStateDidChange(_ jukebox: Jukebox) {
       
        if jukebox.state == .ready {
        
        } else if jukebox.state == .loading  {
            if kAppDelegate.fromPrevious
            {
                jukebox.pause()
                
            }
        }
        else {
            switch jukebox.state
            {
            case .playing:
               
                  NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.PlaybackStateChange), object: nil, userInfo: nil)
                break
            case .paused:
                   NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.PlaybackStateChange), object: nil, userInfo: nil)
                break
            case .ready: break
                
            case .loading: break
                
            case .failed: break
                
            }
        }
    }

    func jukeboxDidUpdateMetadata(_ jukebox: Jukebox, forItem: JukeboxItem) {
    }
}
