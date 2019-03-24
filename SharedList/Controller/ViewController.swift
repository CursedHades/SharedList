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
    
    var frbManager : FirebaseManager?

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "goToLists") {
            
            let listsVC = segue.destination as! ListsViewController
            listsVC.frbManager = frbManager
        }
        else if (segue.identifier == "goToRegister") {
            let registerVC = segue.destination as! RegisterViewController
            registerVC.firebaseManager = frbManager
            
        }
        else if (segue.identifier == "goToLogIn") {
            let logInVC = segue.destination as! LogInViewController
            logInVC.firebaseManager = frbManager
        }
    }

    
}

