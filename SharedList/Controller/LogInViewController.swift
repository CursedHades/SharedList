//
//  LogInViewController.swift
//  SharedList
//
//  Created by Lukasz on 03/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit
import Firebase
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
        
        Auth.auth().signIn(withEmail: emailTextField.text!,
                           password: passwordTextField.text!)
        { (user, error) in
            
            SVProgressHUD.dismiss()
            
            if (error != nil) {
                print("Logging failed: \(error!)")
            }
            else {
                print("Logging sucessfull")
                self.performSegue(withIdentifier: "goToLists", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "goToLists") {
            
            let listsVC = segue.destination as! ListsViewController
            listsVC.frbManager = firebaseManager
        }
    }
}
