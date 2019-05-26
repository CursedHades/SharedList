//
//  FrbChangedObserver.swift
//  SharedList
//
//  Created by Lukasz on 23/05/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase

protocol DataChangedObserverObject : class {
    
    func Update(data : [String : Any?])
    func Id() -> String
}

protocol DataChangedObserverDelegate : class {
    
    func DataUpdated()
}

class DataChangedObserver<T : DataChangedObserverObject> {
    
    let data : T
    weak var delegate : DataChangedObserverDelegate?
    
    private var active = false
    
    init(_ data : T) {
        
        self.data = data
    }
    
    func Activate() {
        if (active == false) {
            frb_utils.ListDbRef(data.Id()).observe(.childChanged, with: self.UpdateCallback)
            active = true
        }
    }
    
    func Deactivate() {
        if (active) {
            frb_utils.ListDbRef(data.Id()).removeAllObservers()
            active = false
        }
    }
    
    private func UpdateCallback(_ childSnap: DataSnapshot) {
        let DataDict = [childSnap.key : childSnap.value]
        self.data.Update(data: DataDict)
        
        if let del = self.delegate {
            del.DataUpdated()
        }
    }
}

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
