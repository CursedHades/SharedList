//
//  ObserversHandler.swift
//  SharedList
//
//  Created by Lukasz on 07/04/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase

class ObserversHandler {
    
    fileprivate typealias HandlerForEventType = (type: DataEventType, handler: DatabaseHandle)
    fileprivate var foo = [HandlerForEventType]()
    fileprivate let dbRef : DatabaseReference
    
    init(_ dbRef: DatabaseReference) {
        self.dbRef = dbRef
    }
    
    deinit {
        RemoveAllObservers()
    }
    
    func AddObserver(eventType: DataEventType,
                     _ handler: @escaping (_ snapshot : DataSnapshot) -> Void) {
        
        if let _ = FindHandler(eventType: eventType) {
            return
        }

        let handler = dbRef.observe(eventType, with: handler)
        let newObserver = HandlerForEventType(type: eventType, handler: handler)
        foo.append(newObserver)
    }
    
    func RemoveObserver(eventType: DataEventType) {
        
        if let handler = FindHandler(eventType: eventType) {
            dbRef.removeObserver(withHandle: handler.handler)
        }
    }
    
    func RemoveAllObservers() {
        
        dbRef.removeAllObservers()
    }
    
    fileprivate func FindHandler(eventType: DataEventType) -> HandlerForEventType? {
        
        return foo.first(where: { (event, _) -> Bool in
            return event == eventType
        })
    }
}
