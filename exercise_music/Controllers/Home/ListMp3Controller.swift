//
//  ListMp3Controller.swift
//  exercise_music
//
//  Created by Billiard ball on 03.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import ObjectMapper
import AVFoundation
import StoreKit

class ListMp3Controller: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var audioPlayerView: UIView!
    @IBOutlet weak var containerview: UIView!
    @IBOutlet weak var songImgView: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var songDesc: UILabel!
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var tapBtn: UIButton!
    @IBOutlet weak var welcommessage: UILabel!
    @IBOutlet weak var backGroundImage: UIImageView!

    // MARK: - Properties
    
    var categoryList = [CategoryObj]()
    var fav_categoryobj: CategoryObj?
    var categoryObj: CategoryObj!
    let service = Service()
    var from:String!
    var selectIndexPath: IndexPath!
    var selectedRadio:String! = ""
    var CategoryFileItems : [JukeboxItem]! = []
    var firstLoad: Bool = true
    var products: [SKProduct] = []
    var playbackEnd: Bool = false
        
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.service.delegate = self
        requestPurchasetoApple()
        compareDevice()
        configure()
        welcomeMethod()
        NotificationCenter.default.addObserver(self, selector: #selector(purchased(sender:)), name: NSNotification.Name(rawValue: NotificationName.Purchased), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackEnded(sender:)), name: NSNotification.Name(rawValue: NotificationName.PlaybackEnded), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.playbackEnd = true
        getCategories()
        setMiniPlayer()
        updateProgressState(sender: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.playbackEnd = false
    }
    
    func requestPurchasetoApple() {
        MusicProduct.store.requestProducts { [weak self] success, products in
              guard let self = self else { return }
            guard success else { return }
              self.products = products!
        }
        if MusicProduct.store.isProductPurchased(MusicProduct.monthlySub) {
            kAppDelegate.purchased = true
        } else {
            kAppDelegate.purchased = false
        }
    }
    
    func getCategories() {
        Utils.Show(controller: self)
        let userid = defaults.string(forKey: USERINFO.user_id)
        self.service.callPostURL(url: URL(string: AppURL.API_POST_CATEGORY_URL)!, parameters: ["user_id": userid!], encodingType: "default", headers: nil)
    }
    
    func compareDevice() {
        
        // - Send subscription message to server
        DispatchQueue.background(delay: 0.0, background: {
            let email = defaults.string(forKey: USERINFO.email)
            self.service.callPostURL(url: URL(string: AppURL.API_COMPARE_DEVICE_URL)!, parameters: ["email": email!, "device_id": kAppDelegate.device_id], encodingType: "default", headers: nil)
            print("successfully sent compare device messages to server.")
        }) {
            
        }
    }
    
    @objc func playbackEnded(sender:Notification?) {
        if self.playbackEnd {
            JukeBoxUtils.sharedInstance.stopAction()
            self.showMessageEndMusic()
        }
    }
    
    private func showMessageEndMusic() {
        // Create the alert controller
        let alertController = UIAlertController(title: "", message: "Congratulations!. You finished exercise.", preferredStyle: .alert)
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            kAppDelegate.sendSessionRequest = true
            Utils.Show(controller: self)
            self.playbackPaused(sender: nil)
        }
        // Add the actions
        alertController.addAction(okAction)
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    func playbackPaused(sender: Notification?) {
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
    
    func configure() {
        self.containerview.layer.cornerRadius = 20
        self.containerview.layer.masksToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgressState(sender:)), name: NSNotification.Name(rawValue: NotificationName.PlaybackStateChange), object: nil)
        self.playPauseBtn.addTarget(self, action: #selector(playPauseClick), for: .touchUpInside)
        self.tapBtn.addActionblock({ (btn) in
            self.from = "mini"
            if let category_name = jukebox.currentItem?.categoryName {
                if let index = self.categoryList.firstIndex(where: { $0.category_name == category_name}) {
                    self.categoryObj = self.categoryList[index]
                    self.performSegue(withIdentifier: "detail_play", sender: self)
                }
            }
        }, for: .touchUpInside)
    }
    
    func welcomeMethod() {
        let date = NSDate()
        let calendar = NSCalendar.current
        let currentHour = calendar.component(.hour, from: date as Date)
        let hourInt = Int(currentHour.description)!
        
        if hourInt >= 12 && hourInt <= 16 {
            welcommessage.text = WelcomeMessage.dayMessage
            backGroundImage.image = UIImage(named: "dayBg")
        }
        else if hourInt >= 7 && hourInt <= 12 {
            welcommessage.text = WelcomeMessage.morningMessage
            backGroundImage.image = UIImage(named: "morningBg")
        }
        else if hourInt >= 16 && hourInt <= 20 {
            welcommessage.text = WelcomeMessage.eveningMessage
            backGroundImage.image = UIImage(named: "eveningBg")
        }
        else if hourInt >= 20 && hourInt <= 24 {
            welcommessage.text = WelcomeMessage.nightMessage
            backGroundImage.image = UIImage(named: "nightBg")
        }
        else if hourInt >= 0 && hourInt <= 7 {
            welcommessage.text = WelcomeMessage.sleeplessMessage
            backGroundImage.image = UIImage(named: "nightBg")
        }
    }
    
    private func showMessage() {
        // Create the alert controller
        let alertController = UIAlertController(title: "Warning!", message: "Internet connect lost. Would you please retry?", preferredStyle: .alert)
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.getCategories()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            print("cancel button clicked")
        }

        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func gotoStats(_ sender: Any) {
        performSegue(withIdentifier: "gotostats", sender: self)
    }
    
    @IBAction func gotoSetting(_ sender: Any) {
        performSegue(withIdentifier: "gotosetting", sender: self)
    }
               
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail_play" {
            let dv = segue.destination as! DetailPlayerController
            dv.from = self.from
            if self.from != "mini" {
                
                dv.categoryItem = self.categoryObj.items![selectIndexPath.row]
                dv.categoryObj = self.categoryObj

                if let fav_cat = self.fav_categoryobj {
                    if fav_cat.category_name! == self.categoryObj.category_name! {
                        dv.isFavorite = true
                        kAppDelegate.isFavorite = true
                    } else {
                        dv.isFavorite = false
                        kAppDelegate.isFavorite = false
                        let favor = fav_cat.items!.filter { $0.item_id! == self.categoryObj.items![selectIndexPath.row].item_id! }
                        if favor.count != 0 {
                            dv.isFavorite = true
                            kAppDelegate.isFavorite = true
                        } else {
                            dv.isFavorite = false
                            kAppDelegate.isFavorite = false
                        }
                    }
                } else {
                    dv.isFavorite = false
                    kAppDelegate.isFavorite = false
                }
                                                
                dv.songName1 = self.categoryList[selectIndexPath.section].items?[selectIndexPath.row].item_name
                dv.songDesc1 =  self.categoryList[selectIndexPath.section].items?[selectIndexPath.row].item_description
                if Reachability.isConnectedToNetwork() {
                    dv.imgURL1 =  self.categoryList[selectIndexPath.section].items?[selectIndexPath.row].item_image
                    dv.URL1  =  URL(string:self.categoryList[selectIndexPath.section].items?[selectIndexPath.row].item_file ?? "")
                }
                else {
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    dv.imgURL1 =  documentsURL.path + (self.categoryList[selectIndexPath.section].items?[selectIndexPath.row].item_image ?? "")
                    dv.URL1  =  documentsURL.appendingPathComponent(self.categoryList[selectIndexPath.section].items?[selectIndexPath.row].item_file ?? "")
                }
                
                DispatchQueue.background(delay: 0.0, background: {
                    let item_id = self.categoryObj.items![self.selectIndexPath.row].item_id
                    print(item_id!)
                    self.service.callPostURL(url: URL(string: AppURL.API_POST_UPDATE_SONG_STATUS)!, parameters: ["item_id": item_id!, "flag": 1], encodingType: "default", headers: nil)
                    print("sent playing number")
                }) {}
                
            } else {
                
                for item in self.categoryObj.items! {
                    if item.item_id! == jukebox.currentItem?.localId! {
                        dv.categoryItem = item
                        break
                    }
                }
                                                
                dv.categoryObj = self.categoryObj
                dv.isFavorite = kAppDelegate.isFavorite
                dv.songName1 = jukebox.currentItem?.localTitle
                dv.songDesc1 =  jukebox.currentItem?.localDesc
                dv.imgURL1 =  jukebox.currentItem?.imgURL
                dv.URL1  = jukebox.currentItem?.URL
                dv.firstLoad = self.firstLoad
                self.firstLoad = false
            }
            dv.jukeboxFileItems = self.CategoryFileItems
        } else if segue.identifier == "premium" {
            let premium = segue.destination as! PremiumController
            premium.products = self.products
        }
    }
}

// MARK: - Custom methods
extension ListMp3Controller {
        
    @objc func purchased(sender: Notification?) {
        kAppDelegate.purchased = true
        self.collectionview.reloadData()
        
        // - Send subscription message to server
        DispatchQueue.background(delay: 0.0, background: {
            let userid = defaults.string(forKey: USERINFO.user_id)
            self.service.callPostURL(url: URL(string: AppURL.API_SUBSCRIPTION_URL)!, parameters: ["user_id": userid!, "device_id": kAppDelegate.device_id], encodingType: "default", headers: nil)
        }) {
            print("successfully sent subscription messages to server.")
        }
    }
    
    @objc func playPauseClick() {
        kAppDelegate.sendSessionRequest = true
        JukeBoxUtils.sharedInstance.playPauseAction()
    }
    
    @objc func updateProgressState(sender:Notification?) {
        if jukebox?.currentItem  != nil
        {
            self.playPauseBtn.isSelected = jukebox.state == .playing
        }
    }
    
    func setBottomPlayerView() {
        if kAppDelegate.isFirstPlaying == true {
            self.audioPlayerView.isHidden = true
        } else {
            if jukebox?.currentItem == nil {
                self.audioPlayerView.isHidden = true
            } else {
                if jukebox.state == .playing || jukebox.state == .paused {
                    self.audioPlayerView.isHidden = false
                }
            }
        }
        self.audioPlayerView.updateConstraints()
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
    }
    
    func setMiniPlayer()
    {
        if jukebox?.currentItem  != nil {
            if (jukebox?.currentItem?.imgURL?.hasPrefix("http"))! {
                self.songImgView.af_setImage(withURL: URL(string: (jukebox?.currentItem?.imgURL!)!)!)
            } else {
                self.songImgView.image = UIImage(contentsOfFile: (jukebox?.currentItem?.imgURL!)!)
            }
            self.songName.text = jukebox?.currentItem?.localTitle
            self.songDesc.text = jukebox?.currentItem?.localDesc
        }
        setBottomPlayerView()
    }
    
    func setJukeBoxItems(completion:@escaping (_ sts: Bool) -> ())
    {
        self.CategoryFileItems.removeAll()
        let ob = self.categoryList[selectIndexPath.section].items![selectIndexPath.row]
        self.CategoryFileItems.append(JukeboxItem(URL: URL(string:(ob.item_file)!)!,localID1:ob.item_id,localTitle: ob.item_name, localDesc:  ob.item_description, imgURL: ob.item_image,downloadName1:ob.download_name,category_image_path : nil,category_id: nil,category_name : self.categoryObj.category_name,lyrics1 : nil
        ))
        completion(true)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDatasource, UICollectionViewDelegateFlowLayout

extension ListMp3Controller: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.categoryList.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoryList[section].items!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Mp3Cell", for: indexPath) as! Mp3Cell
        let menuItem = categoryList[indexPath.section].items?[indexPath.row]
                
        // - Check lock icon regarding purchase condition
        let first_cat_name = categoryList[0].category_name!
        if first_cat_name == "Favorites" {
            cell.lockImg.isHidden = true
        } else {
            if !kAppDelegate.purchased {
                if indexPath.section == 0 && indexPath.row == 0 {
                    cell.lockImg.isHidden = true
                } else {
                    cell.lockImg.isHidden = false
                }
            } else {
                cell.lockImg.isHidden = true
            }
        }
        
        // - configure cell
        
        cell.min_txt.text = (menuItem?.duration)! + " min"
        cell.songName.text = menuItem?.item_name
        cell.songName_constraint.constant = Utils.heightForView(text: (menuItem?.item_name!)!, font: UIFont.systemFont(ofSize: 20.0, weight: .semibold), width: cell.songName.frame.size.width)
        
        if (menuItem?.item_image?.hasPrefix("http"))!
        {
            cell.indicator.isHidden = false
            cell.indicator.startAnimating()
            
            Utils.setAlomFireImage(menuItem?.item_image != nil ? (menuItem?.item_image!)! : "", imageView: cell.songImg, AI: cell.indicator, rad: 0, imageSize:CGSize(width:UIScreen.main.bounds.size.width, height: 200))
        }
        else
        {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            cell.songImg.image =  UIImage(contentsOfFile:documentsURL.path + "/" + (menuItem?.item_image!)!)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.categoryObj = categoryList[indexPath.section]
        
        let first_cat_name = categoryList[0].category_name!
        if first_cat_name == "Favorites" {
            didSelectItem(indexPath: indexPath)
        } else {
            if !kAppDelegate.purchased {
                if indexPath.section == 0 && indexPath.row == 0 {
                    didSelectItem(indexPath: indexPath)
                } else {
                    performSegue(withIdentifier: "premium", sender: self)
                }
            } else {
                didSelectItem(indexPath: indexPath)
            }
        }
    }
    
    func didSelectItem( indexPath: IndexPath) {
        kAppDelegate.isFirstPlaying = false
        self.selectIndexPath = indexPath
        self.setJukeBoxItems { (sts) in
            self.loadItems(indexPath: indexPath)
        }
    }
    
    func loadItems(indexPath: IndexPath) {
        
        kAppDelegate.session_id = ""
        kAppDelegate.isFromDownload = false
        self.from = "sub"
        self.firstLoad = false
        kAppDelegate.isFromFavorite = false
        performSegue(withIdentifier: "detail_play", sender: self)
    }
            
    // set header view and size
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {

        case UICollectionView.elementKindSectionHeader:

            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Mp3HeaderView", for: indexPath) as! Mp3HeaderView

            let header = self.categoryList[indexPath.section].category_name
            headerView.title.text = header
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return CGSize(width: collectionView.frame.width, height: 40.0)
    }
}

extension ListMp3Controller: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.size.width
        return CGSize(width: width * 0.45, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let width = view.frame.size.width
        let inset = width*0.1/3
        return UIEdgeInsets (top: 10, left: inset, bottom: 10, right: inset)
    }
}

//MARK: Service Delegate Methods
extension ListMp3Controller : ServiceDelegate {
    
    func onFault(resultData: [String : Any]?) {
        Utils.HideHud(controller: self)
    }
    func onResult(resultData: Any?) {
        
        // - get session id
        if let categories = Mapper<SessionId>().map(JSON: resultData as! [String : Any]) {
            if let session_id = categories.session_id {
                kAppDelegate.session_id = session_id
                Utils.HideHud(controller: self)                
                self.performSegue(withIdentifier: "statsfromcategory", sender: self)
                return
            }
        }
        
        // - get all category data
        if let categories = Mapper<CategoryList>().map(JSON: resultData as! [String : Any]) {
            if let data = categories.data {
                self.categoryList = data
                if self.categoryList[0].items?.count == 0 {
                    self.categoryList.remove(at: 0)
                    self.fav_categoryobj = nil
                } else {
                    self.fav_categoryobj = self.categoryList[0]
                }
                self.collectionview.reloadData()
                Utils.HideHud(controller: self)
            }
        }
    }
}
