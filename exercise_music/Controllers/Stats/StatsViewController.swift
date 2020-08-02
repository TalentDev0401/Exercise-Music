//
//  StatsViewController.swift
//  exercise_music
//
//  Created by Billiard ball on 06.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import ObjectMapper

class StatsViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var weak_minutes: UILabel!
    @IBOutlet weak var weak_exercises: UILabel!
    @IBOutlet weak var overall_minutes: UILabel!
    @IBOutlet weak var overall_exercises: UILabel!
    
    // MARK: - Properties
    
    let service = Service()
    var playbackEnd: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.service.delegate = self
        Utils.Show(controller: self)
        let user_id = defaults.string(forKey: USERINFO.user_id)
        service.callPostURL(url: URL(string: AppURL.API_POST_STATS_URL)!, parameters: ["user_id": user_id!], encodingType: "default", headers: nil)
        
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
        let mp3 = self.navigationController?.viewControllers.first(where: { (viewcontroller) -> Bool in
            return viewcontroller is ListMp3Controller
        })
        if let mainViewControllerVC = mp3 {
            navigationController?.popToViewController(mainViewControllerVC, animated: true)
        }
    }
    
    @objc func playbackEnded(sender:Notification?) {
        if self.playbackEnd {
            JukeBoxUtils.sharedInstance.stopAction()
            self.showMessageEndMusic1()
        }        
    }
    
    private func showMessageEndMusic1() {
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
extension StatsViewController: ServiceDelegate {
    
    func onFault(resultData: [String : Any]?) {
        Utils.HideHud(controller: self)
        Utils.showToastMessage("UPdating failed.", controller: self)
    }
    func onResult(resultData: Any?) {
        
        if let categories = Mapper<SessionId>().map(JSON: resultData as! [String : Any]) {
            if let session_id = categories.session_id {
                kAppDelegate.session_id = session_id
                
                let user_id = defaults.string(forKey: USERINFO.user_id)
                service.callPostURL(url: URL(string: AppURL.API_POST_STATS_URL)!, parameters: ["user_id": user_id!], encodingType: "default", headers: nil)
                return
            }
        }
        
        // - get session id
        if let categories = Mapper<StatsObj>().map(JSON: resultData as! [String : Any]) {
            Utils.HideHud(controller: self)
            let week_dur = Int(round(categories.week_duration!/60))
            let overall_dur = Int(round(categories.total_duration!/60))
            self.weak_minutes.text = "\(week_dur)"
            self.weak_exercises.text = "\(categories.week_exercise!)"
            self.overall_minutes.text = "\(overall_dur)"
            self.overall_exercises.text = "\(categories.total_exercise!)"
        }
    }
}


