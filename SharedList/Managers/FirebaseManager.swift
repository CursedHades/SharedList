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
        
        authManager = AuthManager()
        listsManager = ListsManager(authManager: authManager)
        invitationManager = InvitationManager(listManager: listsManager)
        
        authManager.delegates.addDelegate(listsManager)
        authManager.delegates.addDelegate(invitationManager)
    }
    
    func PrepareSingleListManager(list: List) -> SingleListManager {
        
        return SingleListManager(list: list, frbManager: self)
    }
}
