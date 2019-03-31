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
    func UserRegistrationFinished(error: Error?)
}

extension AuthManagerDelegate {
    
    func UserStateChanged(loggedIn: Bool) {}
    func UserRegistrationFinished(error: Error?) {}
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
    
    func CreateUser(name: String, email: String, password: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            if (error == nil) {
                let userData = User.Serialize(name: name, email: email)
                let uId = result!.user.uid
                
                frb_utils.UserDbRef(uId).setValue(userData, withCompletionBlock: { (error, userDbRef) in
                    
                    if (error == nil) {
                        self.currentUser = User.Deserialize(id: uId, data: userData)
                    }
                    
                    if let del = self.delegate {
                        del.UserRegistrationFinished(error: error)
                    }
                    
                    return
                })
            }
            else {
                if let del = self.delegate {
                    del.UserRegistrationFinished(error: error)
                }
            }
        }
    }
    
    func LogIn() {
        
    }
    
    func LogOut() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print("singing out failed with errror: \(error)")
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
}
