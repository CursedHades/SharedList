//
//  RegisterViewController.swift
//  SharedList
//
//  Created by Lukasz on 03/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func RegisterPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        
        Auth.auth().createUser(withEmail: emailTextField.text!,
                               password: passwordTextField.text!)
        { (user, error) in
            
            SVProgressHUD.dismiss()
            
            if (error != nil) {
                print("Registrtion failed: \(error!)")
            }
            else {
                print("Registration sucessfull")
                self.performSegue(withIdentifier: "goToLists", sender: self)
            }
        }
    }
}
