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
    let proposalManager : ProposalManager
    let authManager : AuthManager
    
    init () {
        FirebaseApp.configure()
        
        listManager = ListManager()
        proposalManager = ProposalManager(listManager: listManager)
        authManager = AuthManager()
        
        authManager.TryAutoLogIn()
    }
}
