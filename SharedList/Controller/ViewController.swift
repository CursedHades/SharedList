//
//  ViewController.swift
//  SharedList
//
//  Created by Lukasz on 25/02/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var logInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func DisableUI() {
        registerButton.isEnabled = false
        logInButton.isEnabled = false
    }
    
    func EnableUI() {
        registerButton.isEnabled = true
        logInButton.isEnabled = true
    }

    override func viewDidAppear(_ animated: Bool) {
        
        SVProgressHUD.show()
        DisableUI()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            SVProgressHUD.dismiss()
            self.EnableUI()
            
            if (user != nil) {
                self.performSegue(withIdentifier: "goToLists", sender: self)
            }
        }
    }
}

