//
// JukeboxItem.swift
//
// Copyright (c) 2015 Teodor Patraş
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import AVFoundation
import MediaPlayer

protocol JukeboxItemDelegate : class {
    func jukeboxItemDidLoadPlayerItem(_ item: JukeboxItem)
    func jukeboxItemDidUpdate(_ item: JukeboxItem)
    func jukeboxItemDidFail(_ item: JukeboxItem)
}

open class JukeboxItem: NSObject, NSCoding {
    
    public struct Meta {
        fileprivate(set) public var duration: Double?
        fileprivate(set) public var title: String?
        fileprivate(set) public var album: String?
        fileprivate(set) public var artist: String?
        fileprivate(set) public var artwork: UIImage?
    }
    
    // MARK:- Properties -
    
    var identifier = ""
    var delegate: JukeboxItemDelegate?
    fileprivate var didLoad = false
    
    open  var localTitle: String?
    open  var URL: Foundation.URL?
    
    //added by PC
    open  var lyrics: String?
    open  var localDesc: String?
    open  var localId: String?
    open  var imgURL: String?
    open  var downloadName: String?
    //    open  var repeatOn: Bool? = false
    //    open  var shuffleOn: Bool? = false
    open  var categoryId: String?
    open  var categoryName: String?
    open  var categoryImgURL: String?
  
    fileprivate(set) open var playerItem: AVPlayerItem?
    fileprivate (set) open var currentTime: Double?
    fileprivate(set) open lazy var meta = Meta()
    
    
    fileprivate var timer: Timer?
    fileprivate let observedValue = "timedMetadata"
    
    // MARK:- Initializer -
    
    /**
     Create an instance with an URL and local title
     
     - parameter URL: local or remote URL of the audio file
     - parameter localTitle: an optional title for the file
     
     - returns: JukeboxItem instance
     */
    public required init(URL : Foundation.URL, localID1 : String? = nil,localTitle : String? = nil,localDesc : String? = nil,imgURL : String? = nil,downloadName1 : String? = nil,category_image_path : String? = nil,category_id : String? = nil,category_name : String? = nil,lyrics1 : String? = nil) {
       
        self.URL = URL
        self.identifier = (UIDevice.current.identifierForVendor?.uuidString)!
        self.localTitle = localTitle
        self.localDesc = localDesc
        self.imgURL = imgURL
        self.localId = localID1
        self.downloadName = downloadName1
        self.categoryImgURL = category_image_path
        self.categoryId = category_id
        self.categoryName = category_name
        self.lyrics = lyrics1
        super.init()
        configureMetadata()
    }
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(URL, forKey: "URL")
        aCoder.encode(localTitle, forKey: "localTitle")
        aCoder.encode(localId, forKey: "localId")
        aCoder.encode(downloadName, forKey: "downloadName")
        aCoder.encode(localDesc, forKey: "localDesc")
        aCoder.encode(imgURL, forKey: "imgURL")
        aCoder.encode(categoryImgURL, forKey: "categoryImgURL")
        aCoder.encode(categoryId, forKey: "categoryId")
        aCoder.encode(categoryName, forKey: "categoryName")
        aCoder.encode(lyrics, forKey: "lyrics")

    }
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        self.URL = (aDecoder.decodeObject(forKey: "URL") as? URL)!
        self.localTitle = (aDecoder.decodeObject(forKey: "localTitle") as? String)
        self.localDesc = (aDecoder.decodeObject(forKey: "localDesc") as? String)
        self.localId = (aDecoder.decodeObject(forKey: "localId") as? String)
        self.imgURL = (aDecoder.decodeObject(forKey: "imgURL") as? String)
        self.downloadName = (aDecoder.decodeObject(forKey: "downloadName") as? String)
        self.categoryImgURL = (aDecoder.decodeObject(forKey: "categoryImgURL") as? String)
        self.categoryId = (aDecoder.decodeObject(forKey: "categoryId") as? String)
        self.categoryName = (aDecoder.decodeObject(forKey: "categoryName") as? String)
        self.lyrics = (aDecoder.decodeObject(forKey: "lyrics") as? String)
    }
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if change?[NSKeyValueChangeKey(rawValue:"name")] is NSNull {
            delegate?.jukeboxItemDidFail(self)
            return
        }
        if keyPath == observedValue {
            if let item = playerItem , item === object as? AVPlayerItem {
                guard let metadata = item.timedMetadata else { return }
                for item in metadata {
                    meta.process(metaItem: item)
                }
            }
            scheduleNotification()
        }
    }
    
    deinit {
        playerItem?.removeObserver(self, forKeyPath: observedValue)
    }
    
    // MARK: - Internal methods -
    
    func loadPlayerItem() {
        
        if let item = playerItem {
            refreshPlayerItem(withAsset: item.asset)
            delegate?.jukeboxItemDidLoadPlayerItem(self)
            return
        } else if didLoad {
            return
        } else {
            didLoad = true
        }
        
        loadAsync { (asset) -> () in
            if self.validateAsset(asset) {
                self.refreshPlayerItem(withAsset: asset)
                self.delegate?.jukeboxItemDidLoadPlayerItem(self)
            } else {
                self.didLoad = false
            }
        }
    }
    
    func refreshPlayerItem(withAsset asset: AVAsset) {
        playerItem?.removeObserver(self, forKeyPath: observedValue)
        playerItem = AVPlayerItem(asset: asset)
        playerItem?.addObserver(self, forKeyPath: observedValue, options: NSKeyValueObservingOptions.new, context: nil)
        update()
    }
    
    func update() {
        if let item = playerItem {
            meta.duration = item.asset.duration.seconds
            currentTime = item.currentTime().seconds
        }
    }
    
    open override var description: String {
        return "<JukeboxItem:\ntitle: \(String(describing: meta.title))\nalbum: \(String(describing: meta.album))\nartist:\(String(describing: meta.artist))\nduration : \(meta.duration),\ncurrentTime : \(String(describing: currentTime))\nURL: \(URL)>"
    }
    
    // MARK:- Private methods -
    
    fileprivate func validateAsset(_ asset : AVURLAsset) -> Bool {
        var e: NSError?
        asset.statusOfValue(forKey: "duration", error: &e)
        if let error = e {
            var message = "\n\n***** Jukebox fatal error*****\n\n"
            if error.code == -1022 {
                message += "It looks like you're using Xcode 7 and due to an App Transport Security issue (absence of SSL-based HTTP) the asset cannot be loaded from the specified URL: \"\(URL)\".\nTo fix this issue, append the following to your .plist file:\n\n<key>NSAppTransportSecurity</key>\n<dict>\n\t<key>NSAllowsArbitraryLoads</key>\n\t<true/>\n</dict>\n\n"
                fatalError(message)
            }
            return false
        }
        return true
    }
    
    fileprivate func scheduleNotification() {
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(JukeboxItem.notifyDelegate), userInfo: nil, repeats: false)
    }
    
    @objc func notifyDelegate() {
        timer?.invalidate()
        timer = nil
        self.delegate?.jukeboxItemDidUpdate(self)
    }
    
    fileprivate func loadAsync(_ completion: @escaping (_ asset: AVURLAsset) -> ()) {
        let asset = AVURLAsset(url: URL!, options: nil)
        
        asset.loadValuesAsynchronously(forKeys: ["duration"], completionHandler: { () -> Void in
            DispatchQueue.main.async {
                completion(asset)
            }
        })
    }
    
    fileprivate func configureMetadata()
    {
        
        DispatchQueue.global(qos: .background).async {
            let metadataArray = AVPlayerItem(url: self.URL!).asset.commonMetadata
            
            for item in metadataArray
            {
                item.loadValuesAsynchronously(forKeys: [AVMetadataKeySpace.common.rawValue], completionHandler: { () -> Void in
                    self.meta.process(metaItem: item)
                    DispatchQueue.main.async {
                        self.scheduleNotification()
                    }
                })
            }
        }
    }
}

private extension JukeboxItem.Meta {
    mutating func process(metaItem item: AVMetadataItem) {
        
        guard let commonKey = item.commonKey else { return }
        switch commonKey
        {
        case .commonKeyTitle :
            title = item.value as? String
        case .commonKeyAlbumName :
            album = item.value as? String
        case .commonKeyArtist :
            artist = item.value as? String
        case .commonKeyArtwork :
            processArtwork(fromMetadataItem : item)
        default :
            break
        }
    }
    mutating func processArtwork(fromMetadataItem item: AVMetadataItem) {
        guard let value = item.value else { return }
        let copiedValue: AnyObject = value.copy(with: nil) as AnyObject
        
        if let dict = copiedValue as? [AnyHashable: Any] {
            //AVMetadataKeySpaceID3
            if let imageData = dict["data"] as? Data {
                artwork = UIImage(data: imageData)
            }
        } else if let data = copiedValue as? Data{
            //AVMetadataKeySpaceiTunes
            artwork = UIImage(data: data)
        }
    }
}

private extension CMTime {
    var seconds: Double? {
        let time = CMTimeGetSeconds(self)
        guard time.isNaN == false else { return nil }
        return time
    }
}

