//
//  ForgotPasswordController.swift
//  exercise_music
//
//  Created by Billiard ball on 03.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import MessageUI
import ObjectMapper

class ForgotPasswordController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var emailtxt: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    let service = Service()
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        service.delegate = self
        // set corner radius and shadow effect to button
        Utils.shadowEffectBtn(btn: self.sendBtn)
    }
    
    // MARK: - IBActions
    @IBAction func send_email(_ sender: Any) {
        if emailtxt.text! == "" {
            Utils.showAlert("Email missed!", message: "Please input validated email.", controller: self)
            return
        }
//        self.showEmail(reciverId: "\(emailtxt.text!)")
        Utils.Show("Reseting...", controller: self)
        service.callPostURL(url: URL(string: AppURL.API_RESET_PASSWORD_URL)!, parameters: ["email": self.emailtxt.text!], encodingType: "default", headers: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - generate random password
    
    private func generateRandomPassword() -> String {
        let len = 8
        let pswdChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        let rndPswd = String((0..<len).compactMap{ _ in pswdChars.randomElement() })
        return rndPswd
    }
    
    private func showEmail(reciverId: String?) {
        if MFMailComposeViewController.canSendMail() {
            let rndPswd = generateRandomPassword()
            let toRecipents = [reciverId]
            let mc = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(AppName)
            mc.setMessageBody("<p> Your new password: \n" + "\(rndPswd)" + "</p>", isHTML: true)
            mc.setToRecipients(toRecipents as? [String])
            present(mc, animated: true)
        } else {
            Utils.showAlert("", message: "Mail services are not available", controller: self)
        }
    }
}

// MARK: MFMailComposeViewControllerDelegat Method
extension ForgotPasswordController: MFMailComposeViewControllerDelegate {
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
extension ForgotPasswordController : ServiceDelegate {
    func onFault(resultData: [String : Any]?) {
        Utils.HideHud(controller: self)
        let dict = resultData!
        helperOb.toast((dict["msg"] as! String))
    }
    
    func onResult(resultData: Any?) {
        Utils.HideHud(controller: self)
        if resultData != nil {
            let dict = resultData as! [String:Any]
            let status = dict["status"] as! Int
            if status == 1 {
                Utils.showAlert("Success!", message: "Please check your email and confirm new password.", controller: self)
            } else if status == 2 {
                Utils.showAlert("Failed!", message: "The email address doesn't exist.", controller: self)
            } else {
                Utils.showAlert("Failed!", message: "Unknown error occured!", controller: self)
            }
        }
    }
}
