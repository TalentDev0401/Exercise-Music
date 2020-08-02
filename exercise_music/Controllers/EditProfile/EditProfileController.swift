//
//  EditProfileController.swift
//  exercise_music
//
//  Created by Billiard ball on 06.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import ObjectMapper

class EditProfileController: UIViewController {

    @IBOutlet weak var nametxt: UITextField!
    @IBOutlet weak var emailtxt: UITextField!
    @IBOutlet weak var passwordtxt: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var confirm_passwordtxt: UITextField!
    
    let service = Service()
    var playbackEnd: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        service.delegate = self
        
        Utils.shadowEffectBtn(btn: self.saveBtn)
        let name = defaults.string(forKey: USERINFO.username)
        self.nametxt.text = name
        let email = defaults.string(forKey: USERINFO.email)
        self.emailtxt.text = email
        
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
    
    @IBAction func save(_ sender: Any) {
        if self.passwordtxt.text == "" {
            Utils.showAlert("Password missed", message: "Please type your new password", controller: self)
            return
        }
        if self.confirm_passwordtxt.text == "" {
            Utils.showAlert("Password missed", message: "Please confirm your new password", controller: self)
            return
        }
        
        if self.passwordtxt.text! != self.confirm_passwordtxt.text! {
            Utils.showAlert("", message: "Put same password in both fields", controller: self)
            return
        }
        showMessage()
    }
    
    @IBAction func signout(_ sender: Any) {
        defaults.removeObject(forKey: USERINFO.token)
        if jukebox != nil {
            if jukebox.state == .playing {
                JukeBoxUtils.sharedInstance.playPauseAction()
            }
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let sceneDelegate = windowScene.delegate as? SceneDelegate
        else {
          return
        }
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        let navigationController = UINavigationController(rootViewController: nextViewController)
        navigationController.isNavigationBarHidden = true
        sceneDelegate.window?.rootViewController = navigationController
    }
    
    @IBAction func delete_account(_ sender: Any) {
        showDeleteMessage()
    }
    
    // MARK: - Private methods
    private func showMessage() {
        // Create the alert controller
        let alertController = UIAlertController(title: "Warning!", message: "Do you really want to change your password?", preferredStyle: .alert)
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            Utils.Show("Updating...", controller: self)
            self.updatePassword()
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
    
    private func showDeleteMessage() {
        // Create the alert controller
        let alertController = UIAlertController(title: "Warning!", message: "Do you really want to Delete your account?", preferredStyle: .alert)
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            Utils.Show("Deleting...", controller: self)
            let user_id = defaults.string(forKey: USERINFO.user_id)
            self.service.callPostURL(url: URL(string: AppURL.API_DELETE_USER_URL)!, parameters: ["user_id": user_id!], encodingType: "default", headers: nil)
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
    
    private func updatePassword() {
        let user_id = defaults.string(forKey: USERINFO.user_id)
        let email = defaults.string(forKey: USERINFO.email)
        let password = self.passwordtxt.text!
        var flag = 0
        if email != self.emailtxt.text! {
            flag = 1
        }
        let param: [String: Any] = ["flag": flag, "username": self.nametxt.text!, "user_id": user_id!, "email": self.emailtxt.text!, "password": password]
        service.callPostURL(url: URL(string: AppURL.API_UPDATE_PASSWORD_URL)!, parameters: param, encodingType: "default", headers: nil)
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
extension EditProfileController : ServiceDelegate {
    func onFault(resultData: [String : Any]?) {
        Utils.HideHud(controller: self)
        let dict = resultData!
        helperOb.toast((dict["msg"] as! String))
    }
    
    func onResult(resultData: Any?) {
        
        // - get session id
        if let categories = Mapper<SessionId>().map(JSON: resultData as! [String : Any]) {
            if let session_id = categories.session_id {
                kAppDelegate.session_id = session_id
                Utils.HideHud(controller: self)
                self.performSegue(withIdentifier: "statsfromedit", sender: self)
                return
            }
        }
        
        if resultData != nil {
            let dict = resultData as! [String: Any]
            let msg = dict["msg"] as! String
            if msg == "User is deleted successfully!" {
                Utils.HideHud(controller: self)
                
                // - remove all user info
                defaults.removeObject(forKey: USERINFO.token)
                defaults.removeObject(forKey: USERINFO.username)
                defaults.removeObject(forKey: USERINFO.email)
                defaults.removeObject(forKey: USERINFO.password)
                defaults.removeObject(forKey: USERINFO.user_id)
                defaults.removeObject(forKey: USERINFO.extra_time)
                kAppDelegate.delay_time = 0
                if jukebox != nil {
                    if jukebox.state == .playing {
                        JukeBoxUtils.sharedInstance.playPauseAction()
                    }
                }
                
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = windowScene.delegate as? SceneDelegate
                else {
                  return
                }
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
                let navigationController = UINavigationController(rootViewController: nextViewController)
                navigationController.isNavigationBarHidden = true
                sceneDelegate.window?.rootViewController = navigationController
                return
                
            } else if msg == "success!" {
                Utils.HideHud(controller: self)
                Utils.showAlert("Success!", message: "Successfully updated your password.", controller: self)
                return
            }
            let status = dict["status"] as! Int
            if status == 2 {
                Utils.HideHud(controller: self)
                Utils.showAlert("Update failed!", message: "This email already exist", controller: self)
            }
        }
    }
}


