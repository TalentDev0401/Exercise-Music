//
//  SettingsViewController.swift
//  exercise_music
//
//  Created by Billiard ball on 06.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import ObjectMapper

class SettingsViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var delay_txt: UILabel!
    @IBOutlet weak var delay_btn: UIButton!
    @IBOutlet weak var pv_radio_view: UIView!
    @IBOutlet weak var delay_0s: PVRadioButton!
    @IBOutlet weak var delay_10s: PVRadioButton!
    @IBOutlet weak var delay_30s: PVRadioButton!
    @IBOutlet weak var delay_1min: PVRadioButton!
    @IBOutlet weak var delay_3min: PVRadioButton!
    
    // MARK: - Properties
        
    var radioButtonGroup: PVRadioButtonGroup!
    var playbackEnd: Bool = false
    let service = Service()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        service.delegate = self
        configure_PVRadioButtonGroup()
        var delay_time = defaults.integer(forKey: USERINFO.extra_time)
        if delay_time >= 60 {
            delay_time = Int(delay_time/60)
            self.delay_txt.text = "\(delay_time) min"
        } else {
            self.delay_txt.text = "\(delay_time) s"
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hiddenRadioView))
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
        
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
    
    // MARK: - Private methods
    
    @objc func hiddenRadioView() {
        self.pv_radio_view.isHidden = true
    }
    
    private func configure_PVRadioButtonGroup() {
        self.pv_radio_view.layer.cornerRadius = 2.0
        self.pv_radio_view.layer.masksToBounds = true
        radioButtonGroup = PVRadioButtonGroup()
        radioButtonGroup.delegate = self
        radioButtonGroup.appendToRadioGroup(radioButtons: [delay_0s,delay_10s,delay_30s, delay_1min, delay_3min])
        self.pv_radio_view.isHidden = true
    }
    
    // MARK: - IBActions
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func setDelayTime(_ sender: Any) {
        self.pv_radio_view.isHidden = false
        self.pv_radio_view.fadeIn(0.5)
    }
    
    @IBAction func EditProfile(_ sender: Any) {
        performSegue(withIdentifier: "editprofile", sender: self)
    }
    
    @IBAction func InviteShare(_ sender: Any) {
        performSegue(withIdentifier: "invite", sender: self)
    }
    
    @IBAction func AboutUs(_ sender: Any) {
        performSegue(withIdentifier: "aboutus", sender: self)
    }
    
    @IBAction func Feedback(_ sender: Any) {
        performSegue(withIdentifier: "feedback", sender: self)
    }
    
    @IBAction func RateUs(_ sender: Any) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string:AppURLLive)!, options: [:], completionHandler: nil)
        } else {
           UIApplication.shared.openURL(URL(string:AppURLLive)!)
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

extension SettingsViewController: RadioButtonGroupDelegate {
    
    func radioButtonClicked(button: PVRadioButton) {
        print(button.titleLabel?.text ?? "")
        
        var delay_time: Int!
        guard let delay = button.titleLabel?.text else {
            self.pv_radio_view.fadeOut()
            self.pv_radio_view.isHidden = true
            return
        }
        if delay == "0 s" {
            delay_time = 0
        } else if delay == "10 s" {
            delay_time = 10
        } else if delay == "30 s" {
            delay_time = 30
        } else if delay == "1 min" {
            delay_time = 60
        } else {
            delay_time = 180
        }
        
        let user_id = defaults.string(forKey: USERINFO.user_id)
        service.callPostURL(url: URL(string: AppURL.API_POST_DELAY_TIME_URL)!, parameters: ["user_id": user_id!, "extra_time": delay_time!], encodingType: "default", headers: nil)
        kAppDelegate.delay_time = delay_time
        self.delay_txt.text = button.titleLabel?.text
        self.pv_radio_view.fadeOut()
        self.pv_radio_view.isHidden = true
    }
}

//MARK: Service Delegate Methods
extension SettingsViewController : ServiceDelegate {
    
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
                self.performSegue(withIdentifier: "statsfromsettings", sender: self)
            }
        }
    }
}
