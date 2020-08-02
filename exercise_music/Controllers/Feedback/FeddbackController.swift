//
//  FeddbackController.swift
//  exercise_music
//
//  Created by Billiard ball on 06.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import MessageUI
import ObjectMapper

class FeddbackController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var mobileField: UITextField!
    @IBOutlet weak var descView: UITextView!
    @IBOutlet weak var submitBtn: UIButton!
    
    var isEdit_description = false
    var playbackEnd: Bool = false
    
    let service = Service()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        service.delegate = self
        Utils.shadowEffectBtn(btn: self.submitBtn)
        self.descView.layer.cornerRadius = 5.0
        self.descView.layer.masksToBounds = true
        self.descView.delegate = self
        self.descView.text = "Description"
        self.descView.textColor = UIColor.gray
        
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
    
    @IBAction func submit(_ sender: Any) {
        if validateFields()
        {
            let str1 = "Name: " + self.nameField.text! + "\nMobile: "
            let str2 =  self.mobileField.text! + "\nDis: " + self.descView.text!
            self.showEmail(forDemand: str1 + str2, reciverId: "\(ReciverEmailID)")
        }
    }
    
    // MARK: - Private methods
    func validateFields() -> Bool
    {
        if (self.nameField.text?.isEmpty)! || (self.descView.text?.isEmpty)!
        {
            helperOb.toast(ToastMsg.EnterValue)
            return false
        }
        return true
    }
    
    func showEmail(forDemand demadText: String?, reciverId: String?) {
                
        if MFMailComposeViewController.canSendMail() {
            let toRecipents = [reciverId]
            let mc = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(AppName)
            mc.setMessageBody("\(demadText!)", isHTML: true)
            mc.setToRecipients(toRecipents as? [String])
            present(mc, animated: true)
        } else {
            Utils.showAlert("", message: "Mail services are not available", controller: self)
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

extension FeddbackController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !self.isEdit_description {
            self.descView.text = ""
            self.isEdit_description = true
            self.descView.textColor = UIColor.black
        }
    }
}

// MARK: MFMailComposeViewControllerDelegat Method
extension FeddbackController:MFMailComposeViewControllerDelegate {
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
extension FeddbackController : ServiceDelegate {
    
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
                self.performSegue(withIdentifier: "statsfromfeedback", sender: self)
            }
        }
    }
}
