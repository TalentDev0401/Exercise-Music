//
//  DetailPlayerController.swift
//  exercise_music
//
//  Created by Billiard ball on 03.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import ObjectMapper

class DetailPlayerController: UIViewController {
    
    // MARK: - IBoutlets
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var playPauseBtn: CustomUIButton!
    @IBOutlet weak var leftDuration: UILabel!
    @IBOutlet weak var currentDuration: UILabel!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var songName_constraint: NSLayoutConstraint!
    @IBOutlet weak var songDescTxtView: UITextView!
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var progressParentView: CustomView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    let service = Service()
    var CategoryItemIndex : Int!
    var isFavorite:Bool!
    var circularSlider:EFCircularSlider!
    var from:String!
    var selectedRadio:String! = ""
    var downloadedIdArray: [Int] = []
    var firstLoad: Bool = false
    var categoryItem : CategoryItem!
    var categoryObj: CategoryObj!
    var songName1:String! = ""
    var songDesc1:String! = ""
    var imgURL1:String! = ""
    var URL1:URL!
    var jukeboxFileItems : [JukeboxItem]! = []
    var updateSession: Bool = false
    var playbackEnd: Bool = false

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.service.delegate = self
        
        setCircularView()
        self.configureView()
        getDownlodedIds()
        if self.from != "mini" {
            intialiseJukebox()
        }
        setData()
        self.loadImage()
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgressState(sender:)), name: NSNotification.Name(rawValue: NotificationName.PlaybackProgressChange), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateInfoState(sender:)), name: NSNotification.Name(rawValue: NotificationName.PlaybackInfoChange), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackEnded(sender:)), name: NSNotification.Name(rawValue: NotificationName.PlaybackEnded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(progressBarUpdate(sender:)), name: NSNotification.Name(rawValue: NotificationName.ProgressSong), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(progressBarCompleted(sender:)), name: NSNotification.Name(rawValue: NotificationName.ProgressSongCompleted), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackPaused(sender:)), name: NSNotification.Name(rawValue: NotificationName.PlaybackPaused), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.playbackEnd = true
        updateProgressState(sender: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.playbackEnd = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.from != "mini" {
            if jukebox.state == .paused || jukebox.state == .loading || jukebox.state == .failed
            || jukebox.state == .ready {
                if kAppDelegate.delay_time != 0 {
                    if kAppDelegate.timer == nil {
                        kAppDelegate.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.playSong), userInfo: nil, repeats: true)
                    }
                } else {
                    JukeBoxUtils.sharedInstance.play(index: 0)
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    @objc private func playSong() {
        kAppDelegate.counter += 1
        if kAppDelegate.delay_time == kAppDelegate.counter {
            kAppDelegate.timer?.invalidate()
            kAppDelegate.timer = nil
            kAppDelegate.counter = 0
            JukeBoxUtils.sharedInstance.play(index: 0)
        }
    }
    
    private func configureView() {
        
        // set value
        self.songName.text = self.songName1
        self.songName_constraint.constant = Utils.heightForView(text:
            self.songName1, font: UIFont.systemFont(ofSize: 32.0, weight: .semibold), width: self.songName.frame.size.width)
        self.songDescTxtView.text = self.songDesc1
        if self.isFavorite {
            self.favBtn.setImage(UIImage(named: "fav"), for: .normal)
            self.favBtn.isSelected = true
        }
    }
    
    private func getDownlodedIds() {
        downloadedIdArray = RealmUtils.sharedInstance.getDownloadObjectIds()
        let ids = downloadedIdArray.filter { $0 == Int(self.categoryItem.item_id!)}
        if ids.count != 0 {
            self.downloadBtn.isSelected = true
            self.downloadBtn.setImage(UIImage(named: "download_finished"), for: .normal)
            self.downloadBtn.isUserInteractionEnabled = false
        }
    }
    
    private func loadImage() {
        guard let _ = self.categoryItem.item_image else { return }
        if (self.categoryItem.item_image?.hasPrefix("http"))!
        {
            Utils.setAlomFireImage(self.categoryItem.item_image != nil ?
                (self.categoryItem.item_image!) : "", imageView: self.songImage, AI:
                nil, rad: 0, imageSize:CGSize(width:UIScreen.main.bounds.size.width, height: 200))
        } else {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            self.songImage.image =  UIImage(contentsOfFile:documentsURL.path + "/" + (self.categoryItem.item_image!))
        }
    }
}

//MARK: IBActions
extension DetailPlayerController {
        
    @IBAction func goBack(_ sender: Any) {
        if kAppDelegate.timer != nil {
            kAppDelegate.timer?.invalidate()
            kAppDelegate.timer = nil
            kAppDelegate.counter = 0
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func download(_ sender: Any) {
       
        Utils.Show("Downloading...", controller: self)
        
        let realmObj = DownloadObj()
        realmObj.item_id = self.categoryItem.item_id!
        realmObj.item_name = self.categoryItem.item_name!
        realmObj.item_description = categoryItem.item_description!
        realmObj.download_name = categoryItem.download_name!
        realmObj.item_file_path =  categoryItem.item_file!
        realmObj.item_image_path =  categoryItem.item_image!
        realmObj.category_name = self.categoryObj.category_name
        
        self.service.downloadAudioFiles(obj:realmObj ,downloaded:self.downloadBtn.isSelected, completion: { (sts) in
            print("download is true")
            Utils.HideHud(controller: self)
            self.downloadBtn.isSelected = !self.downloadBtn.isSelected
            self.downloadBtn.setImage(UIImage(named: "download_finished"), for: .normal)
            
            DispatchQueue.background(delay: 0.0, background: {
                let item_id = self.categoryItem.item_id!
                print(item_id)
                self.service.callPostURL(url: URL(string: AppURL.API_POST_UPDATE_SONG_STATUS)!, parameters: ["item_id": item_id, "flag": 0], encodingType: "default", headers: nil)
                print("sent playing number")
            }) {}
        })
    }
    
    @IBAction func favorite(_ sender: Any) {
        if !self.favBtn.isSelected {
            self.favBtn.setImage(UIImage(named: "fav"), for: .normal)
            self.favBtn.isSelected = true
            
            // - send request
            set_favorite(fav: true)
        } else {
            self.favBtn.setImage(UIImage(named: "unfav"), for: .normal)
            self.favBtn.isSelected = false
            set_favorite(fav: false)
        }
    }
    
    func set_favorite(fav: Bool) {
        let item_id = self.categoryItem.item_id!
        let user_id = defaults.string(forKey: USERINFO.user_id)
        self.service.callPostURL(url: URL(string: AppURL.API_POST_FAVORITES_URL)!, parameters: ["item_id": item_id, "user_id": user_id!, "status": fav], encodingType: "default", headers: nil)
    }
    
    @IBAction func playPauseClick(_ sender: Any) {
        self.playPauseBtn.isSelected = !self.playPauseBtn.isSelected
        kAppDelegate.sendSessionRequest = true
        JukeBoxUtils.sharedInstance.playPauseAction()
    }
}

// MARK: - Custom methods
extension DetailPlayerController {
    
    private func showMessage() {
        // Create the alert controller
        let alertController = UIAlertController(title: "", message: "Congratulations!. You finished exercise.", preferredStyle: .alert)
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            kAppDelegate.sendSessionRequest = true
            self.updateSession = true
            Utils.Show(controller: self)
            self.playbackPaused(sender: nil)            
        }
        // Add the actions
        alertController.addAction(okAction)
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func intialiseJukebox() {
        JukeBoxUtils.sharedInstance.resetJukebox()
        JukeBoxUtils.sharedInstance.configure(items: self.jukeboxFileItems)
        jukebox.playIndex = 0
        if kAppDelegate.delay_time != 0 {
            if kAppDelegate.timer == nil {
                kAppDelegate.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.playSong), userInfo: nil, repeats: true)
            }
        } else {
            JukeBoxUtils.sharedInstance.play(index: 0)
        }
    }
    
    private func setCircularView() {
        circularSlider = EFCircularSlider(frame: CGRect(x: 10 , y: 10, width: progressParentView.frame.size.width - 20, height: progressParentView.frame.size.height - 20))
        
        circularSlider.handleType = .bigCircle
        circularSlider.handleColor = Utils.uiColorString(hStr: colorAboutText.sliderHandle)
        circularSlider.filledColor = Utils.uiColorString(hStr: colorAboutText.sliderFilled)
        circularSlider.unfilledColor = UIColor.white
        circularSlider.currentValue = 0.0
        self.progressParentView.addSubview(circularSlider)
        self.progressParentView.bringSubviewToFront(circularSlider)
        self.progressParentView.bringSubviewToFront(self.playPauseBtn)
    }
    
    @objc func playbackPaused(sender: Notification?) {
        if kAppDelegate.sendSessionRequest == true {
            kAppDelegate.sendSessionRequest = false
            let user_id = defaults.string(forKey: USERINFO.user_id)
            let dur : Double = kAppDelegate.currentTime
            let minutes = Int(floor(dur))
            let playing_time = minutes*60 + Int(dur*100)%100
            let param: [String: Any] = ["session_id": kAppDelegate.session_id, "user_id": user_id!, "item_id": (jukebox.currentItem?.localId)!, "playing_time": playing_time, "date": Utils.getTimeStamp()]
            service.callPostURL(url: URL(string: AppURL.API_POST_SESSION_URL)!, parameters: param, encodingType: "default", headers: nil)
        }
    }
    
    @objc func updateInfoState(sender:Notification?) {
        if jukebox != nil {
            self.title = jukebox?.currentItem?.localTitle
            if (jukebox?.currentItem?.imgURL?.hasPrefix("http"))! {
                self.songImage.af_setImage(withURL: URL(string: (jukebox?.currentItem?.imgURL!)!)!)
            } else {
                self.songImage.image = UIImage(contentsOfFile: (jukebox?.currentItem?.imgURL!)!)
            }

            self.songName.text = jukebox?.currentItem?.localTitle
            self.songDescTxtView.text = jukebox?.currentItem?.localDesc
            self.indicator.alpha = 1
            self.circularSlider.isUserInteractionEnabled = false
            self.playPauseBtn.alpha = 0
            
            currentDuration.text = "0.00"
            leftDuration.text = "0.00"
            circularSlider.currentValue = 0.0
        }
    }
    @objc func updateProgressState(sender:Notification?) {
        if jukebox?.currentItem != nil
        {
            self.title = jukebox?.currentItem?.localTitle
            let left : Double = kAppDelegate.leftDuration
            let dur : Double = kAppDelegate.duration
            let curr : Double =  kAppDelegate.currentTime
            if curr <= dur {
                currentDuration.text = (jukebox.state == .playing || jukebox.state == .paused) ? String(format: "%.2f", curr) : "0.00"
            }
            if left >= 0.0 {
                leftDuration.text = (jukebox.state == .playing || jukebox.state == .paused) ? ("-" + String(format: "%.2f",left)) : "0.00"
            } else {
                self.indicator.alpha = 1
            }
            if kAppDelegate.fromPrevious {
                kAppDelegate.fromPrevious = false
                // jukebox.play(atIndex: subCategoryIndex)
                self.playPauseBtn.isSelected = true
            } else if jukebox.currentItem?.currentTime != nil
            {
                self.indicator.alpha = ((jukebox.currentItem?.currentTime)! <= 0.00) ? 1 : 0
                self.playPauseBtn.alpha = ((jukebox.currentItem?.currentTime)! <= 0.00) ? 0 : 1
            }
            if jukebox.state == .loading || jukebox.state == .ready
            {
                self.indicator.alpha = 1
                self.playPauseBtn.alpha = 0
            }
            self.circularSlider.isUserInteractionEnabled = (self.indicator.alpha == 1) ? false:true
            self.playPauseBtn.isSelected = jukebox.state == .playing
            circularSlider.currentValue = Float(curr/dur) * 100
        }
    }
    
    @objc func playbackEnded(sender:Notification?) {
        if self.playbackEnd {
            JukeBoxUtils.sharedInstance.stopAction()
            self.playPauseBtn.isSelected = !self.playPauseBtn.isSelected
            self.showMessage()
        }        
    }
    
    func setData() {
        if jukebox.currentItem != nil {
            if self.from == "mini" {
                if jukebox.state != .paused {
                    jukebox.resumePlayback()
                }
                if (self.imgURL1?.hasPrefix("http"))!
                {
                    self.songImage.af_setImage(withURL: URL(string: self.imgURL1!)!)
                }
                else{
                    self.songImage.image = UIImage(contentsOfFile: self.imgURL1)
                }
            } else if jukebox.state == .loading || jukebox.state == .failed
                || jukebox.state == .ready {
                self.indicator.alpha = 1
                self.playPauseBtn.alpha = 0
                if (self.imgURL1?.hasPrefix("http"))! {
                    self.songImage.af_setImage(withURL: URL(string: self.imgURL1!)!)
                } else {
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    self.songImage.image = UIImage(contentsOfFile: documentsURL.path + imgURL1)
                }
            } else if self.from != "mini" {
                if (self.imgURL1?.hasPrefix("http"))! {
                    self.songImage.af_setImage(withURL: URL(string: self.imgURL1!)!)
                } else{
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    self.songImage.image = UIImage(contentsOfFile: documentsURL.path + imgURL1)
                }
            }
            self.songName.text = self.songName1
            self.songDescTxtView.text = self.songDesc1
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func progressBarUpdate(sender:Notification?) {
        
    }
    @objc func progressBarCompleted(sender:Notification?) {
        Utils.HideHud(controller: self)
        self.downloadBtn.isUserInteractionEnabled = false
    }
}

//MARK: Service Delegate Methods
extension DetailPlayerController : ServiceDelegate {
    
    func onFault(resultData: [String : Any]?) {
        Utils.HideHud(controller: self)
        Utils.showToastMessage("Updating failed.", controller: self)
    }
    func onResult(resultData: Any?) {
        
        // - get session id
        if let categories = Mapper<SessionId>().map(JSON: resultData as! [String : Any]) {
            if let session_id = categories.session_id {
                kAppDelegate.session_id = session_id
                
                if self.updateSession {
                    self.updateSession = false
                    Utils.HideHud(controller: self)
                    self.performSegue(withIdentifier: "statsfromplayer", sender: self)
                }
            }
        }
    }
}
