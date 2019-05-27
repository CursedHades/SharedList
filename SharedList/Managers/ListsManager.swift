//
//  ListsManager.swift
//  SharedList
//
//  Created by Lukasz on 18/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation
import Firebase

protocol ListsManagerDelegate : class {
    
    func DataLoaded()
    func NewListAdded()
    func ListRemoved()
    func ListUpdated()
}

extension List : DataChangedObserverObject {
    
    func Id() -> String {
        return self.id
    }
}

//class ListWithObserver
//{
//    let list : List
//}

class ListsManager {
    
    weak var delegate : ListsManagerDelegate? = nil
    
    fileprivate var observersHandler : ObserversHandler?
    fileprivate var wrapedLists = [DataChangedObserver<List>]()
    
    fileprivate let authManager : AuthManager
    
    var listCount : Int {
        get { return wrapedLists.count }
    }
    
    init(authManager: AuthManager)
    {
        self.authManager = authManager
    }
    
    func GetList(_ idx : Int) -> List? {
        if (idx < listCount) {
            return wrapedLists[idx].data
        }
        return nil
    }
    
    fileprivate func InitObserverHandler() {
        let userListsDbRef = frb_utils.UserListsDbRef()
        observersHandler = ObserversHandler(userListsDbRef)
    }
    
    func LoadData() {
        
        let userListsDbRef = frb_utils.UserListsDbRef()
        userListsDbRef.observeSingleEvent(of: .value)
        { (listsSnapshot) in
            
            if (listsSnapshot.exists() == false) {
                if let del = self.delegate {
                    del.DataLoaded()
                }
                return
            }
            
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
    
    func ActivateObservers() {
        
        if let _ = observersHandler {
            InitObserverHandler()
        }
        
        observersHandler!.AddObserver(eventType: .childAdded, ListsKeysChildAdded)
        observersHandler!.AddObserver(eventType: .childRemoved, ListsKeysChildRemoved)
        
        for listObserver in wrapedLists {
            listObserver.Activate()
        }
    }
    
    
    // MARK: - Lists Keys Observers Handlers
    fileprivate func ListsKeysChildAdded(_ listKeySnapshot: DataSnapshot) {
        
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
    
    fileprivate func ListsKeysChildRemoved(_ listKeySnapshot: DataSnapshot) {
        
        for (index, wraper) in self.wrapedLists.enumerated() {
            
            if (wraper.data.id == listKeySnapshot.key) {
                
                wraper.Deactivate()
                self.wrapedLists.remove(at: index)
                
                if let del = self.delegate {
                    del.ListRemoved()
                }
                return
            }
        }
    }
    
    // MARK: - Lists Manipulations
    func AddNewList(title: String) {
        
        let dbRef = Database.database().reference()
        
        let newListRef = frb_utils.ListsTableDbRef().childByAutoId()
        let newListKey = newListRef.key!
        
        let newItemsRef = frb_utils.ItemsTableDbRef().childByAutoId()
        let newItemsKey = newItemsRef.key!
        
        let userId = Auth.auth().currentUser!.uid
        
        var serializedList = List.Serialize(title: title, owner_id: userId, items_id: newItemsKey)
        serializedList["users"] = ["\(userId)" : authManager.currentUser?.name]
        
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
            let listId = wrapedLists[index].data.id
            let itemsId = wrapedLists[index].data.items_id
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
    
    fileprivate func AddLoadedList(id: String, data: [String : Any]) {
        
        let newList = List.Deserialize(id: id, data: data)
        let observer = DataChangedObserver(newList)
        observer.delegate = self
        wrapedLists.append(observer)
    }
    
    fileprivate func ListLoaded(_ id : String) -> Bool {
        
        if FindList(id) != nil {
            return true
        }
        return false
    }
    
    fileprivate func FindList(_ id : String) -> List? {
        
        for wraper in wrapedLists {
            if (wraper.data.id == id) {
                return wraper.data
            }
        }
        return nil
    }
    
    fileprivate func Cleanup() {
        
        observersHandler = nil
        delegate = nil
        
        for listObserver in wrapedLists {
            listObserver.Deactivate()
        }
        wrapedLists.removeAll()
    }
}

// MARK: - ListObserverDelegate
extension ListsManager : DataChangedObserverDelegate {
    
    func DataUpdated() {
        if let del = delegate {
            del.ListUpdated()
        }
    }
}

// MARK: - AuthManagerDelegate
extension ListsManager : AuthManagerDelegate {
    
    func UserLogedOut() {
        Cleanup()
    }
    
    func UserLogedIn() {
        InitObserverHandler()
    }
}
