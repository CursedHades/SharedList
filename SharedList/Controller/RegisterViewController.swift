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
    
    var firebaseManager : FirebaseManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func RegisterPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        
        Auth.auth().createUser(withEmail: emailTextField.text!,
                               password: passwordTextField.text!)
        { (user, error) in
            
            if (error != nil) {
                SVProgressHUD.dismiss()
                print("Registrtion failed: \(error!)")
            }
            else {
                let userDbRef = Database.database().reference().child("users").child(user!.user.uid)
                userDbRef.setValue(["email": user!.user.email!])
                { error, snapshot in
                    
                    SVProgressHUD.dismiss()
                    
                    if (error != nil) {
                        print("Adding user to firebase failed: \(error!)")
                    }
                    else {
                        self.performSegue(withIdentifier: "goToLists", sender: self)
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "goToLists") {
            
            let listsVC = segue.destination as! ListsViewController
            listsVC.listManager = firebaseManager?.listManager
        }
    }
}
