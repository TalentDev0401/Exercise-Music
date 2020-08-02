//
//  InviteShareController.swift
//  exercise_music
//
//  Created by Billiard ball on 06.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import MessageUI
import ObjectMapper

class InviteShareController: UIViewController {

    @IBOutlet weak var invite_email: UIButton!
    @IBOutlet weak var invite_whatsapp: UIButton!
    
    let service = Service()
    var playbackEnd: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        service.delegate = self
        Utils.shadowEffectBtn(btn: self.invite_email)
        Utils.shadowEffectBtn(btn: self.invite_whatsapp)
        
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
    
    @IBAction func goback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func invite_Email(_ sender: Any) {
        self.showEmail(reciverId: "\(ReciverEmailID)")
    }
    
    func showEmail(reciverId: String?) {
        if MFMailComposeViewController.canSendMail() {
            let toRecipents = [reciverId]
            let mc = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(AppName)
            mc.setMessageBody("<p> \(kShareContent)\n" + "\(AppURLLive)" + "</p>", isHTML: true)
            mc.setToRecipients(toRecipents as? [String])
            present(mc, animated: true)
        } else {
            Utils.showAlert("", message: "Mail services are not available", controller: self)
        }
    }
    
    @IBAction func invite_Whatsapp(_ sender: Any) {
        let urlStr = "\(kShareContent) \n" + AppURLLive
        let urlWhats = "whatsapp://send?text=\(urlStr)"//phone=\(PhoneNumber)&
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed){
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL){
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(whatsappURL)
                    }
                }
                else {
                    print("Install Whatsapp")
                    Utils.showAlert("", message: "Please install whatsapp", controller: self)
                }
            }
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

// MARK: MFMailComposeViewControllerDelegat Method
extension InviteShareController:MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
            self.navigationController?.popViewController(animated: true)
        case .sent:
            print("Mail sent")
            self.navigationController?.popViewController(animated: true)
        case .failed:
            print("Mail sent failure: \(String(describing: error?.localizedDescription))")
        default:
            break
        }
        // Close the Mail Interface
        dismiss(animated: true,completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: Service Delegate Methods
extension InviteShareController : ServiceDelegate {
    
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
                self.performSegue(withIdentifier: "statsfrominvite", sender: self)
            }
        }
    }
}
