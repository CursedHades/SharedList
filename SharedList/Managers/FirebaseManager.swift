//
//  FirebaseManager.swift
//  SharedList
//
//  Created by Lukasz on 05/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase

class FirebaseManager {
    
    let listsManager : ListsManager
    let invitationManager : InvitationManager
    let authManager : AuthManager
    
    init () {
        FirebaseApp.configure()
        
        listsManager = ListsManager()
        invitationManager = InvitationManager(listManager: listsManager)
        authManager = AuthManager()
        
        authManager.delegates.addDelegate(listsManager)
        authManager.delegates.addDelegate(invitationManager)
    }
}
