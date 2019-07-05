//
//  FirebaseManager.swift
//  SharedList
//
//  Created by Lukasz on 05/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase

class FirebaseManager
{
    let authManager : AuthManager
    
    init ()
    {
        FirebaseApp.configure()
        
        authManager = AuthManager()
    }
    
    func PrepareSingleListManager(list: List) -> SingleListManager
    {
        return SingleListManager(list: list, authManager: authManager)
    }
    
    func PrepareListsManager() -> ListsManager
    {
        return ListsManager(authManager: authManager)
    }
    
    func PrepareInvitationManager(listsManager: ListsManager) -> InvitationManager
    {
        return InvitationManager(listsManager: listsManager)
    }
}
