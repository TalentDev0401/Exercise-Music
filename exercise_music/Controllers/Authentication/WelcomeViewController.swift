//
//  WelcomeViewController.swift
//  exercise_music
//
//  Created by Billiard ball on 03.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var signinBtn: UIButton!

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set corner radius and shadow effect to button
        Utils.shadowEffectBtn(btn: self.signupBtn)
        Utils.shadowEffectBtn(btn: self.signinBtn)
    }
    
    // MARK: - IBActions
    
    @IBAction func gotoSignup(_ sender: Any) {
        performSegue(withIdentifier: "gotosignup", sender: self)
    }
    
    @IBAction func gotoSignin(_ sender: Any) {
        performSegue(withIdentifier: "gotosignin", sender: self)
    }
    
}
