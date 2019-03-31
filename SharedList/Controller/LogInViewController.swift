//
//  LogInViewController.swift
//  SharedList
//
//  Created by Lukasz on 03/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit
import SVProgressHUD

class LogInViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    var firebaseManager : FirebaseManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func LogInPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        firebaseManager?.authManager.delegate = self
        firebaseManager?.authManager.LogIn(email: email,
                                           password: password)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "goToLists") {
            
            let listsVC = segue.destination as! ListsViewController
            listsVC.frbManager = firebaseManager
        }
    }
}

extension LogInViewController : AuthManagerDelegate {
    
    func UserLoginFinished(error: Error?) {
        
        SVProgressHUD.dismiss()
        firebaseManager?.authManager.delegate = nil
        if error == nil {
            self.performSegue(withIdentifier: "goToLists", sender: self)
        }
    }
}
