//
//  ListManager.swift
//  SharedList
//
//  Created by Lukasz on 18/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation
import Firebase

protocol ListManagerDelegate : class {
    
    func DataLoaded()
    func NewListAdded()
    func ListRemoved()
    func ListUpdated()
}

protocol ListObserverDelegate : class {
    
    func ListUpdated()
}

class ListChangedObserver {
    
    let list : List
    weak var delegate : ListObserverDelegate?
    
    private var active = false
    
    init(_ list : List) {
        self.list = list
    }
    
    func Activate() {
        if (active == false) {
            frb_utils.ListDbRef(list.id).observe(.childChanged, with: self.UpdateCallback)
            active = true
        }
    }
    
    func Deactivate() {
        frb_utils.ListDbRef(list.id).removeAllObservers()
        active = false
    }
    
    private func UpdateCallback(_ childSnap: DataSnapshot) {
        let DataDict = [childSnap.key : childSnap.value]
        self.list.Update(data: DataDict)
        
        if let del = self.delegate {
            del.ListUpdated()
        }
    }
}

class ListManager {
    
    weak var delegate : ListManagerDelegate? = nil
    
    fileprivate var observers = [DataEventType: DatabaseHandle?]()
    fileprivate var activeObservers = 0
    
    fileprivate var wrapedLists = [ListChangedObserver]()
    
    var listCount : Int {
        get { return wrapedLists.count }
    }
    
    func GetList(_ idx : Int) -> List? {
        if (idx < listCount) {
            return wrapedLists[idx].list
        }
        return nil
    }
    
    func LoadData() {
        
        let userListsDbRef = frb_utils.UserListsDbRef()
        userListsDbRef.observeSingleEvent(of: .value)
        { (listsSnapshot) in
            
            let listsIds = (listsSnapshot.value! as! [String : Any]).keys
            var listsCounter = listsIds.count

            for (listId) in listsIds {
                
                let listDbRef = frb_utils.ListDbRef(listId)
                listDbRef.observeSingleEvent(of: .value, with:{ (listSnapshot) in
                    
                    self.AddLoadedList(id: listId, data: listSnapshot.value as! [String : Any])
                    
                    listsCounter = listsCounter - 1
                    
                    if let del = self.delegate {
                        if (listsCounter == 0) {
                            del.DataLoaded()
                        }
                        else {
                            del.NewListAdded()
                        }
                    }
                })
            }
        }
    }
    
    func ActivateObservers()
    {
        activeObservers = activeObservers + 1
        
        if (observers[.childAdded] == nil) {
            
            let userListsDbRef = frb_utils.UserListsDbRef()
            observers[.childAdded] = userListsDbRef.observe(.childAdded)
            { (listKeySnapshot) in
                
                let listId = listKeySnapshot.key
                if self.ListLoaded(listId) {
                    return
                }
                
                let listDbRef = frb_utils.ListDbRef(listId)
                listDbRef.observeSingleEvent(of: .value, with: { (listSnapshot) in

                    self.AddLoadedList(id: listId, data: listSnapshot.value as! [String : Any])
                    
                    if let del = self.delegate {
                        del.NewListAdded()
                    }
                })
            }
        }
        
        if (observers[.childRemoved] == nil) {
            
            let listsKeyDbRef = frb_utils.UserListsDbRef()
            observers[.childRemoved] = listsKeyDbRef.observe(.childRemoved)
            { (listKeySnapshot) in
                
                for (index, wraper) in self.wrapedLists.enumerated() {
                    
                    if (wraper.list.id == listKeySnapshot.key) {
                        
                        wraper.Deactivate()
                        self.wrapedLists.remove(at: index)
                        
                        if let del = self.delegate {
                            del.ListRemoved()
                        }
                        return
                    }
                }
            }
        }
        
        for listObserver in wrapedLists {
            listObserver.Activate()
        }
    }
    
    func DeactivateObservers()
    {
        if (activeObservers == 0) { fatalError("No active observers.") }
        
        activeObservers = activeObservers - 1
        
        if (activeObservers == 0) {
            
            let listsKeyDbRef = frb_utils.UserListsDbRef()
            
            listsKeyDbRef.removeAllObservers()
            observers.removeAll()
            
            for listObserver in wrapedLists {
                listObserver.Deactivate()
            }
        }
    }
    
    fileprivate func AddLoadedList(id: String, data: [String : Any]) {
        let newList = List.Deserialize(id: id, data: data)
        let observer = ListChangedObserver(newList)
        observer.delegate = self
        wrapedLists.append(observer)
    }
    
    func AddNewList(title: String) {
        
        let dbRef = Database.database().reference()
        
        let newListRef = frb_utils.ListsDbRef().childByAutoId()
        let newListKey = newListRef.key!
        
        let newItemsRef = frb_utils.ItemsDbRef().childByAutoId()
        let newItemsKey = newItemsRef.key!
        
        let userId = Auth.auth().currentUser!.uid
        
        var serializedList = List.Serialize(title: title, owner_id: userId, items_id: newItemsKey)
        serializedList["users"] = ["\(userId)" : true]
        
        let updateData = ["users/\(userId)/lists/\(newListKey)" : true,
                          "lists/\(newListKey)" : serializedList,
                          "items/\(newItemsKey)/list_id" : newListKey] as [String : Any]
        
        dbRef.updateChildValues(updateData)
        { (error, snapshot) in
            
            if (error != nil) {
                print("New list add failed with error: \(error!)")
            }
        }
    }
    
    func RemoveList(index: Int) {
        
        if (index < listCount)
        {
            let listId = wrapedLists[index].list.id
            let itemsId = wrapedLists[index].list.items_id
            let listUsersDbRef = Database.database().reference().child("lists/\(listId)/users")
            
            listUsersDbRef.observeSingleEvent(of: .value) { (usersSnapshot) in
                
                let usersDict = usersSnapshot.value as! [String : Any]
                
                var updateData = ["lists/\(listId)" : NSNull(),
                                  "items/\(itemsId)" : NSNull()] as [String : Any]
                
                for userId in usersDict.keys {
                    updateData["users/\(userId)/lists/\(listId)"] = NSNull()
                }
                
                Database.database().reference().updateChildValues(updateData)
            }
        }
    }
    
    func GetListById(_ id: String, completionHandler: @escaping (_ list: List?) -> Void) {
        
        let listDbRef = frb_utils.ListDbRef(id)
        listDbRef.observeSingleEvent(of: .value) { (listSnapshot) in
            
            if let listData = listSnapshot.value as? [String : String] {
                let list = List.Deserialize(id: id, data: listData)
                completionHandler(list)
            }
            else {
                completionHandler(nil)
            }
        }
    }
    
    fileprivate func ListLoaded(_ id : String) -> Bool {
        
        if FindList(id) != nil {
            return true
        }
        return false
    }
    
    fileprivate func FindList(_ id : String) -> List? {
        
        for wraper in wrapedLists {
            if (wraper.list.id == id) {
                return wraper.list
            }
        }
        return nil
    }
}

extension ListManager : ListObserverDelegate {
    
    func ListUpdated() {
        if let del = delegate {
            del.ListUpdated()
        }
    }
}
