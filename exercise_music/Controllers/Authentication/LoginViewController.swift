//
//  ViewController.swift
//  exercise_music
//
//  Created by Billiard ball on 02.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import ObjectMapper

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var emailtxt: UITextField!
    @IBOutlet weak var passwordtxt: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    // MARK: - Properties
    let service = Service()
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.service.delegate = self
        
        // set corner radius and shadow effect to button
        Utils.shadowEffectBtn(btn: self.loginBtn)
        
        let email = UserDefaults.standard.string(forKey: USERINFO.email)
        let password = UserDefaults.standard.string(forKey: USERINFO.password)
        self.emailtxt.text = email
        self.passwordtxt.text = password
    }

    // MARK: - IBActions
    
    @IBAction func login(_ sender: Any) {
        if emailtxt.text!.isEmpty {
            Utils.showAlert("Email missed.", message: "Please input email.", controller: self)
            return
        }
        if passwordtxt.text!.isEmpty {
            Utils.showAlert("Password missed.", message: "Please input password.", controller: self)
            return
        }
        
        // send signup request to server
        Utils.Show(controller: self)
        let param: [String: Any] = ["email": emailtxt.text!, "password": passwordtxt.text!]
        self.service.callPostURL(url: URL(string: AppURL.API_POST_SIGNIN_URL)!, parameters: param, encodingType: "default", headers: nil)
    }
    
    @IBAction func forgotpassword(_ sender: Any) {
        performSegue(withIdentifier: "forgotpassword", sender: self)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK: Service Delegate Methods
extension LoginViewController : ServiceDelegate {
    
    func onFault(resultData: [String : Any]?) {
        Utils.HideHud(controller: self)
        Utils.showAlert("Authentication failed.", message: "Please type correct info.", controller: self)
    }
    func onResult(resultData: Any?) {
        Utils.HideHud(controller: self)
        
        if resultData != nil {
            let signup:Signup! = Mapper<Signup>().map(JSON: resultData as! [String : Any])
            
            if signup.status! == 1 {
                // Save user's info
                UserDefaults.standard.set(signup.username, forKey: USERINFO.username)
                UserDefaults.standard.set(self.emailtxt.text!, forKey: USERINFO.email)
                UserDefaults.standard.set(self.passwordtxt.text!, forKey: USERINFO.password)
                UserDefaults.standard.set(signup.token!, forKey: USERINFO.token)
                UserDefaults.standard.set(signup.user_id!, forKey: USERINFO.user_id)
                UserDefaults.standard.set(signup.extra_time!, forKey: USERINFO.extra_time)
                kAppDelegate.delay_time = Int(signup.extra_time!)!
                performSegue(withIdentifier: "listfromsignin", sender: self)
            } else if signup.status! == 0 {
                Utils.showAlert("Authentication failed", message: "Invalid email or password. please type credential info correctly.", controller: self)
            }
            
        }
    }
}

