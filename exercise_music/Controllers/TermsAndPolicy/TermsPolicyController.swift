//
//  TermsPolicyController.swift
//  exercise_music
//
//  Created by Billiard ball on 06.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

class TermsPolicyController: UIViewController {
    
    @IBOutlet weak var aboutTextView: UITextView!

    let service = Service()
    override func viewDidLoad() {
        super.viewDidLoad()
        service.delegate = self
        showMessage()
    }
    
    @IBAction func goback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private methods
    private func showMessage() {
        Utils.Show("Loading...", controller: self)
        service.callPostURL(url: URL(string: AppURL.API_ABOUT_US_URL)!, parameters: nil, encodingType: "default", headers: nil)
    }
}

//MARK: Service Delegate Methods
extension TermsPolicyController : ServiceDelegate {
    func onFault(resultData: [String : Any]?) {
        Utils.HideHud(controller: self)
        let dict = resultData!
        helperOb.toast((dict["msg"] as! String))
    }
    
    func onResult(resultData: Any?) {
        Utils.HideHud(controller: self)
        if resultData != nil {
            let dict = resultData as! [String:Any]
            var str:String = ""
            if dict["status"] as! Int == 1 { //terms_conditions
                 str = "<html><body style=color:\(colorAboutText.color);background-color:\(colorAboutText.background)>"
                    + "<p align=justify>"
                    + "\((dict["data"] as! [String:Any])["terms_conditions"]!)"
                    + "</p>"
                    + "</font>"
                    + "</body></html>"
            } else {
                 str = "<html><body style=color:\(colorAboutText.color);background-color:\(colorAboutText.background)>"
                    + "<p align=justify>"
                    + "\(dict["msg"]!)"
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

