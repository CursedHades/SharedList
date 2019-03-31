//
//  ViewController.swift
//  SharedList
//
//  Created by Lukasz on 25/02/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit
import SVProgressHUD

class ViewController: UIViewController {
    
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var logInButton: UIButton!
    
    var frbManager : FirebaseManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DisableUI()
        
        frbManager?.authManager.delegate = self
        frbManager?.authManager.TryAutoLogIn()
    }
    
    func DisableUI() {
        SVProgressHUD.show()
        registerButton.isEnabled = false
        logInButton.isEnabled = false
    }
    
    func EnableUI() {
        SVProgressHUD.dismiss()
        registerButton.isEnabled = true
        logInButton.isEnabled = true
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

extension ViewController : AuthManagerDelegate {
    
    func UserStateChanged(loggedIn: Bool) {
        EnableUI()
        
        frbManager?.authManager.delegate = nil
        
        if (loggedIn) {
            performSegue(withIdentifier: "goToLists", sender: self)
        }
    }
}

