//
//  FirebaseManager.swift
//  SharedList
//
//  Created by Lukasz on 05/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase

class FirebaseManager {
    
    var listManager = ListManager()
    var proposalManager = ProposalManager()
    
    init () {
        FirebaseApp.configure()
    }
}
