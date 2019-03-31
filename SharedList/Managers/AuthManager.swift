//
//  AuthManager.swift
//  SharedList
//
//  Created by Lukasz on 31/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase

protocol AuthManagerDelegate: class {
    
    func UserStateChanged(loggedIn: Bool)
}

class AuthManager {
    
    var currentUser : User?
    weak var delegate : AuthManagerDelegate?
    
    func TryAutoLogIn() {
        
        Auth.auth().addStateDidChangeListener { (auth, userOpt) in
            
            if let user = userOpt {
                
                self.GetUserById(user.uid, completionHandler: { (loadedUser) in
                    self.currentUser = loadedUser
                    
                    if let del = self.delegate {
                        del.UserStateChanged(loggedIn: true)
                    }
                })
            }
            else {
                if let del = self.delegate {
                    del.UserStateChanged(loggedIn: false)
                }
            }
        }
    }
    
    func GetUserById(_ id: String, completionHandler: @escaping (_ user: User?) -> Void) {
        
        frb_utils.UserDbRef(id).observeSingleEvent(of: .value, with: { (userSnapshot) in
            if let userData = userSnapshot.value as? [String : Any] {
                let user = User.Deserialize(id: id, data: userData)
                completionHandler(user)
            }
            else {
                completionHandler(nil)
            }
        })
    }
    
//    }
//    Auth.auth().addStateDidChangeListener { (auth, user) in
//
//    SVProgressHUD.dismiss()
//    self.EnableUI()
//
//    if (user != nil) {
//    self.performSegue(withIdentifier: "goToLists", sender: self)
//    }
//    }
}
