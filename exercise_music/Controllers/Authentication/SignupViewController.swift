//
//  SignupViewController.swift
//  exercise_music
//
//  Created by Billiard ball on 03.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import ObjectMapper

class SignupViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var nametxt: UITextField!
    @IBOutlet weak var emailtxt: UITextField!
    @IBOutlet weak var passwordtxt: UITextField!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var confirm_passwordtxt: UITextField!
    @IBOutlet weak var checkbox: VKCheckbox!
    
    // MARK: - Properties
    
    let service = Service()
    private var isOn: Bool!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.InitializeCheckbox()
        self.service.delegate = self
        // set corner radius and shadow effect to button
        Utils.shadowEffectBtn(btn: self.signupBtn)
    }
    
    // MARK: - IBActions
    
    @IBAction func signup(_ sender: Any) {
        
        if nametxt.text!.isEmpty {
            Utils.showAlert("Name missed", message: "Please input name.", controller: self)
            return
        }
        if emailtxt.text!.isEmpty {
            Utils.showAlert("Email missed", message: "Please input email.", controller: self)
            return
        }
        if passwordtxt.text!.isEmpty {
            Utils.showAlert("Password missed", message: "Please input password", controller: self)
            return
        }
        if !self.isOn {
            Utils.showAlert("Checkbox missed", message: "By clicking checkbox, please accept Terms and Privacy Policy.", controller: self)
            return
        }
        
        // send signup request to server
        Utils.Show(controller: self)
        let param: [String: Any] = ["username": nametxt.text!, "email": emailtxt.text!, "password": passwordtxt.text!]
        self.service.callPostURL(url: URL(string: AppURL.API_POST_SIGNUP_URL)!, parameters: param, encodingType: "default", headers: nil)
    }
    
    @IBAction func termspolicy(_ sender: Any) {
        performSegue(withIdentifier: "termspolicy", sender: self)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Private methods

extension SignupViewController {
    // Initialize Checkbox
    private func InitializeCheckbox() {
        
        // Customized checkbox
        checkbox.line             = .thin
        checkbox.bgColorSelected  = .clear
        checkbox.bgColor          = UIColor.white
        checkbox.backgroundColor = UIColor.white
        checkbox.color            = UIColor.red
        checkbox.borderColor      = UIColor.clear
        checkbox.borderWidth      = 1
        checkbox.cornerRadius     = 2

        // Handle custom checkbox callback
        checkbox.checkboxValueChangedBlock = {
            isOn in
            print("Custom checkbox is \(isOn ? "ON" : "OFF")")
            self.isOn = isOn
        }
    }
}

//MARK: Service Delegate Methods
extension SignupViewController : ServiceDelegate {
    
    func onFault(resultData: [String : Any]?) {
        Utils.HideHud(controller: self)
        if let resultdata = resultData {
            let data = resultdata["msg"] as! String
            Utils.showAlert("", message: "\(data)", controller: self)
        }
        
    }
    func onResult(resultData: Any?) {
        Utils.HideHud(controller: self)
      //  DispatchQueue.main.async {
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
            performSegue(withIdentifier: "listfromsignup", sender: self)
        } else if signup.status! == 0 {
            Utils.showAlert("", message: "This email already exist.", controller: self)
        }
    }
}
