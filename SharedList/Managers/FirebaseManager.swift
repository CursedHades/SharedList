//
//  FirebaseManager.swift
//  SharedList
//
//  Created by Lukasz on 05/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase

class FirebaseManager {

//    struct Observation<T : Any> {
//        weak var observer : FrbManagerAuthDelegate?
//    }
//
//    private var observers = [ObjectIdentifier : Observation<FrbManagerAuthDelegate>]()
//
//    func AddObserver(_ observer : FrbManagerAuthDelegate) {
//        let id = ObjectIdentifier(observer)
//        observers[id] = Observation(observer: observer)
//    }
//
//    func RemoveObserver(_ observer : FrbManagerAuthDelegate) {
//        let id = ObjectIdentifier(observer)
//        observers.removeValue(forKey: id)
//    }
    
    var listManager = ListManager()
    var proposalManager = ProposalManager()
    
    init () {
        FirebaseApp.configure()
    }
}
