//
//  AuthManager.swift
//  SharedList
//
//  Created by Lukasz on 31/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase
import MulticastDelegateSwift

protocol AuthManagerDelegate: class {
    
    func UserRegistered()
    func UserRegistrationFailed(error: Error?)
    
    func UserLogedOut()
    func UserLogedIn()
    func UserLogInFailed(error: Error?)
}

extension AuthManagerDelegate {
    
    func UserRegistered() {}
    func UserRegistrationFailed(error: Error?) {}
    
    func UserLogedOut() {}
    func UserLogedIn() {}
    func UserLogInFailed(error: Error?) {}
}


class AuthManager {
    
    var currentUser : User?
    
    let delegates = MulticastDelegate<AuthManagerDelegate>()

    
    func TryAutoLogIn() {
        
        Auth.auth().addStateDidChangeListener { (auth, userOpt) in
            
            if let user = userOpt {
                
                self.GetUserById(user.uid, completionHandler: { (loadedUser) in
                    self.currentUser = loadedUser
                    
                    self.delegates.invokeDelegates({ (delegate) in
                        delegate.UserLogedIn()
                    })
                })
            }
            else {
                self.delegates.invokeDelegates({ (delegate) in
                    delegate.UserLogInFailed(error: NSError())
                })
            }
        }
    }
    
    func CreateUser(name: String, email: String, password: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            if (error != nil) {
                self.delegates.invokeDelegates({ (delegate) in
                    delegate.UserRegistrationFailed(error: error)
                })
                return
            }
            
            let userData = User.Serialize(name: name, email: email)
            let uId = result!.user.uid
            
            frb_utils.UserDbRef(uId).setValue(userData, withCompletionBlock: { (error, userDbRef) in
                
                if (error == nil) {
                    self.currentUser = User.Deserialize(id: uId, data: userData)
                
                    self.delegates.invokeDelegates({ (delegate) in
                        delegate.UserRegistered()
                        delegate.UserLogedIn()
                    })
                }
                else {
                    self.delegates.invokeDelegates({ (delegate) in
                        delegate.UserRegistrationFailed(error: error)
                    })
                }
            })
        }
    }
    
    func LogIn(email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if (error != nil) {
                self.delegates.invokeDelegates({ (delegate) in
                    delegate.UserLogInFailed(error: error)
                })
                return
            }
            
            self.GetUserById(result!.user.uid, completionHandler: { (user) in
                
                self.currentUser = user
                self.delegates.invokeDelegates({ (delegate) in
                    delegate.UserLogedIn()
                })
            })
        }
    }
    
    func LogOut() {
        
        do {
            try Auth.auth().signOut()
        }
        catch {
            print("singing out failed with errror: \(error)")
        }
        
        currentUser = nil
        self.delegates.invokeDelegates { (delegate) in
            delegate.UserLogedOut()
        }
    }
    
    func GetUserById(_ id: String, completionHandler: @escaping (_ user: User) -> Void) {
        
        frb_utils.UserDbRef(id).observeSingleEvent(of: .value, with: { (userSnapshot) in
            
            let userData = userSnapshot.value as! [String : Any]
            let user = User.Deserialize(id: id, data: userData)
            completionHandler(user)
        })
    }
}
