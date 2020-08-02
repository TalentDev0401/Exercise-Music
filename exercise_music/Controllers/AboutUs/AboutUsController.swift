//
//  AboutUsController.swift
//  exercise_music
//
//  Created by Billiard ball on 06.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import ObjectMapper

class AboutUsController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var aboutTextView: UITextView!
    
    let service = Service()
    var playbackEnd: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        service.delegate = self
        showMessage()
        
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
    
    // MARK: - Private methods
    private func showMessage() {
        Utils.Show("Loading...", controller: self)
        service.callPostURL(url: URL(string: AppURL.API_ABOUT_US_URL)!, parameters: nil, encodingType: "default", headers: nil)
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
extension AboutUsController : ServiceDelegate {
    func onFault(resultData: [String : Any]?) {
        Utils.HideHud(controller: self)
        let dict = resultData!
        helperOb.toast((dict["msg"] as! String))
    }
    
    func onResult(resultData: Any?) {
        Utils.HideHud(controller: self)
        
        // - get session id
        if let categories = Mapper<SessionId>().map(JSON: resultData as! [String : Any]) {
            if let session_id = categories.session_id {
                kAppDelegate.session_id = session_id
                
                self.performSegue(withIdentifier: "statsfromabout", sender: self)
                return
            }
        }
        
        if resultData != nil {
            let dict = resultData as! [String:Any]
            var str:String = ""
            if dict["status"] as! Int == 1 { //terms_conditions
                 str = "<html><body style=color:\(colorAboutText.color);background-color:\(colorAboutText.background)>"
                    + "<p align=justify>"
                    + "\((dict["data"] as! [String:Any])["about_us"]!)"
                    + "</p>"
                    + "</font>"
                    + "</body></html>"
            } else {
                 str = "<html><body style=color:\(colorAboutText.color);background-color:\(colorAboutText.background)>"
                    + "<p align=justify>"
                    + "\((dict["data"] as! [String:Any])["message"]!)"
                    + "</p>"
                    + "</font>"
                    + "</body></html>"
            }
            let htmlData = NSString(string: str).data(using: String.Encoding.utf8.rawValue)
            let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
            let attributedString = try! NSAttributedString(data: htmlData!,
                                                           options: options,
                                                           documentAttributes: nil)
            aboutTextView.attributedText = attributedString
            Utils.HideHud(controller: self)
        }
    }
}
