//
//  PremiumController.swift
//  exercise_music
//
//  Created by Billiard ball on 09.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import StoreKit
import ObjectMapper

class PremiumController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var upgradeBtn: UIButton!
    @IBOutlet weak var restoreBtn: UIButton!
    
    var products: [SKProduct] = []
    var playbackEnd: Bool = false
    
    let service = Service()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        service.delegate = self
        
        Utils.shadowEffectBtn(btn: self.upgradeBtn)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackEnded(sender:)), name: NSNotification.Name(rawValue: NotificationName.PlaybackEnded), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.playbackEnd = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.playbackEnd = false
    }
    
    // MARK: - IBActions
    
    @IBAction func goback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func UpgradePremium(_ sender: Any) {
        self.purchaseItemIndex(index: 0)
    }
    
    @IBAction func restorePurchase(_ sender: Any) {
        MusicProduct.store.restorePurchases()
    }
    
    private func purchaseItemIndex(index: Int) {
      MusicProduct.store.buyProduct(products[index]) { [weak self] success, productId in
        guard let self = self else { return }
        guard success else {
          let alertController = UIAlertController(title: "Failed to purchase product",
                                                  message: "Cannot connect to iTunes Store",
                                                  preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: "OK", style: .default))
          self.present(alertController, animated: true, completion: nil)
          return
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Purchased"), object: nil, userInfo: nil)
        self.navigationController?.popViewController(animated: true)
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
}

//MARK: Service Delegate Methods
extension PremiumController : ServiceDelegate {
    
    func onFault(resultData: [String : Any]?) {
        Utils.HideHud(controller: self)
        Utils.showToastMessage("Updating failed.", controller: self)
    }
    func onResult(resultData: Any?) {
        
        // - get session id
        if let categories = Mapper<SessionId>().map(JSON: resultData as! [String : Any]) {
            if let session_id = categories.session_id {
                kAppDelegate.session_id = session_id
                Utils.HideHud(controller: self)
                self.performSegue(withIdentifier: "statsfrompremium", sender: self)
            }
        }
    }
}
