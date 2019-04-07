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
    
    func UserAutoLoginFinished(loggedIn: Bool)
    func UserRegistrationFinished(error: Error?)
    func UserLoginFinished(error: Error?)
    func UserLogedOut(userId: String)
}

extension AuthManagerDelegate {
    
    func UserAutoLoginFinished(loggedIn: Bool) {}
    func UserRegistrationFinished(error: Error?) {}
    func UserLoginFinished(error: Error?) {}
    func UserLogedOut(userId: String) {}
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
                        delegate.UserAutoLoginFinished(loggedIn: true)
                    })
                })
            }
            else {
                self.delegates.invokeDelegates({ (delegate) in
                    delegate.UserAutoLoginFinished(loggedIn: false)
                })
            }
        }
    }
    
    func CreateUser(name: String, email: String, password: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            if (error != nil) {
                self.delegates.invokeDelegates({ (delegate) in
                    delegate.UserRegistrationFinished(error: error)
                })
                return
            }
            
            let userData = User.Serialize(name: name, email: email)
            let uId = result!.user.uid
            
            frb_utils.UserDbRef(uId).setValue(userData, withCompletionBlock: { (error, userDbRef) in
                
                if (error == nil) {
                    self.currentUser = User.Deserialize(id: uId, data: userData)
                }
                
                self.delegates.invokeDelegates({ (delegate) in
                    delegate.UserRegistrationFinished(error: error)
                })
            })
        }
    }
    
    func LogIn(email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if (error != nil) {
                self.delegates.invokeDelegates({ (delegate) in
                    delegate.UserLoginFinished(error: error)
                })
                return
            }
            
            self.GetUserById(result!.user.uid, completionHandler: { (userOpt) in
                
                if let user = userOpt {
                    self.currentUser = user
                }
                self.delegates.invokeDelegates({ (delegate) in
                    delegate.UserLoginFinished(error: (userOpt != nil) ? nil : NSError())
                })
            })
        }
    }
    
    func LogOut() {
        
        let userId = currentUser!.id
        
        do {
            try Auth.auth().signOut()
        }
        catch {
            print("singing out failed with errror: \(error)")
        }
        
        currentUser = nil
        self.delegates.invokeDelegates { (delegate) in
            delegate.UserLogedOut(userId: userId)
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
