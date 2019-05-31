//
//  FrbChangedObserver.swift
//  SharedList
//
//  Created by Lukasz on 23/05/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase

class ChangedObserver {
    
    private let dbRef : DatabaseReference
    private var active = false
    
    private var dataChangedCallback : (DataSnapshot) -> Void
    
    init (dbRef : DatabaseReference,
          dataChangedCallback: @escaping (DataSnapshot) -> Void)
    {
        self.dbRef = dbRef
        self.dataChangedCallback = dataChangedCallback
    }
    
    deinit
    {
        Deactivate()
    }
    
    func Activate()
    {
        if (active == false)
        {
            dbRef.observe(.childChanged, with: self.dataChangedCallback)
            active = true
        }
    }
    
    func Deactivate()
    {
        if (active)
        {
            dbRef.removeAllObservers()
            active = false
        }
    }
}
