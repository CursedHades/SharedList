//
//  FirebaseManager.swift
//  SharedList
//
//  Created by Lukasz on 05/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase

class FirebaseManager {
    
    let listManager : ListManager
    let invitationManager : InvitationManager
    let authManager : AuthManager
    
    init () {
        FirebaseApp.configure()
        
        listManager = ListManager()
        invitationManager = InvitationManager(listManager: listManager)
        authManager = AuthManager()
        
        authManager.delegates.addDelegate(listManager)
        authManager.delegates.addDelegate(invitationManager)
        authManager.TryAutoLogIn()
    }
}
