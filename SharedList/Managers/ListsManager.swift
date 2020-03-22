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

class ListWithObserver
{
    let list : List
    
    private let listChangedCallback : () -> Void
    private var observer : ChangedObserver? = nil
    
    init(list : List, listChangedCallback: @escaping () -> Void)
    {
        self.list = list
        self.listChangedCallback = listChangedCallback
    }
    
    func Activate()
    {
        if (observer == nil)
        {
            let listDbRef = frb_utils.ListDbRef(list.id)
            
            observer = ChangedObserver(dbRef: listDbRef, dataChangedCallback: Updated(snapshot:))
            observer?.Activate()
        }
    }
    
    private func Updated(snapshot : DataSnapshot)
    {
        let listData = [snapshot.key : snapshot.value]
        self.list.Update(data: listData)
        
        self.listChangedCallback()
    }
}

class ListsManager
{
    weak var delegate : ListsManagerDelegate? = nil
    
    fileprivate let authManager : AuthManager
    fileprivate let obsererversManager : ObserversHandler
    fileprivate var observerActive : Bool = false
    
    fileprivate var data = [ListWithObserver]()
    
    var listCount : Int {
        get { return data.count }
    }
    
    init(authManager: AuthManager)
    {
        self.authManager = authManager
        
        let userListsDbRef = frb_utils.UserListsDbRef()
        obsererversManager = ObserversHandler(userListsDbRef)
    }
    
    func GetList(_ idx : Int) -> List?
    {
        if (idx < listCount)
        {
            return data[idx].list
        }
        return nil
    }
    
    func LoadData()
    {
        let userListsDbRef = frb_utils.UserListsDbRef()
        userListsDbRef.observeSingleEvent(of: .value)
        { (listsSnapshot) in
            
            if (listsSnapshot.exists() == false)
            {
                if let del = self.delegate
                {
                    del.DataLoaded()
                    self.ActivateObservers()
                }
                return
            }
            
            let listsIds = (listsSnapshot.value! as! [String : Any]).keys
            var listsCounter = listsIds.count

            for (listId) in listsIds
            {
                let listDbRef = frb_utils.ListDbRef(listId)
                listDbRef.observeSingleEvent(of: .value)
                { (listSnapshot) in
                    
                    let listData = listSnapshot.value! as! [String : Any]
                    _ = self.AddListWithObserver(id: listId, data: listData)
                    
                    listsCounter = listsCounter - 1
                    
                    if let del = self.delegate
                    {
                        if (listsCounter == 0)
                        {
                            del.DataLoaded()
                            self.ActivateObservers()
                        }
                        else
                        {
                            del.NewListAdded()
                        }
                    }
                }
            }
        }
    }
    
    func AddNewList(title: String)
    {
        let newListRef = frb_utils.ListsTableDbRef().childByAutoId()
        let newListKey = newListRef.key!
        
        let newItemsRef = frb_utils.ItemsTableDbRef().childByAutoId()
        let newItemsKey = newItemsRef.key!
        
        let userId = Auth.auth().currentUser!.uid
        
        let creationDate = Date().timeIntervalSince1970
        
        var serializedList = List.Serialize(title: title,
                                            owner_id: userId,
                                            items_id: newItemsKey,
                                            creationDate: creationDate)
        
        serializedList["users"] = ["\(userId)" : authManager.currentUser?.name]
        
        let updateData = ["users/\(userId)/lists/\(newListKey)" : true,
                          "lists/\(newListKey)" : serializedList,
                          "items/\(newItemsKey)/list_id" : newListKey] as [String : Any]
        
        frb_utils.DbRef().updateChildValues(updateData)
        { (error, snapshot) in
            
            if (error != nil) {
                print("New list add failed with error: \(error!)")
            }
        }
    }
    
    func RemoveList(index: Int)
    {
        if (index < listCount)
        {
            let list = data[index].list
            let listUsersDbRef = frb_utils.ListUsersDbRef(list.id)

            listUsersDbRef.observeSingleEvent(of: .value) { (usersSnapshot) in

                let usersDict = usersSnapshot.value as! [String : Any]

                var updateData = ["lists/\(list.id)" : NSNull(),
                                  "items/\(list.items_id)" : NSNull()] as [String : Any]

                for userId in usersDict.keys
                {
                    updateData["users/\(userId)/lists/\(list.id)"] = NSNull()
                }
                
                frb_utils.DbRef().updateChildValues(updateData)
            }
        }
    }
    
    func GetListById(_ id: String, completionHandler: @escaping (_ list: List?) -> Void)
    {
        let listDbRef = frb_utils.ListDbRef(id)
        listDbRef.observeSingleEvent(of: .value)
        { (listSnapshot) in
            
            if let listData = listSnapshot.value as? [String : Any]
            {
                let list = List.Deserialize(id: id, data: listData)
                completionHandler(list)
            }
            else {
                completionHandler(nil)
            }
        }
    }
    
    func AddCurrentUserToList(list: List, completion: @escaping() -> Void)
    {
        let userId = authManager.currentUser!.id
        let updateData = [frb_utils.UserInListPath(listId: list.id, userId: userId) : authManager.currentUser!.name,
                          frb_utils.ListInUserListsPath(userId: userId, listId: list.id) : true] as [String : Any]
        
        frb_utils.DbRef().updateChildValues(updateData)
        { (error, dbRef) in
            completion()
        }
    }
    
    func SortListsByCreationDate()
    {
        data = data.sorted(by: {$0.list.creation_date < $1.list.creation_date })
    }
    
    fileprivate func ActivateObservers()
    {
        if (observerActive == false)
        {
            obsererversManager.AddObserver(eventType: .childAdded, ListsKeysChildAdded)
            obsererversManager.AddObserver(eventType: .childRemoved, ListsKeysChildRemoved)
            
            observerActive = true
        }
    }
    
    
    // MARK: - Lists Keys Observers Handlers
    fileprivate func ListsKeysChildAdded(_ listKeySnapshot: DataSnapshot)
    {
        let listId = listKeySnapshot.key
        if (FindListIndex(listId) != nil)
        {
            return
        }
        
        let listDbRef = frb_utils.ListDbRef(listId)
        listDbRef.observeSingleEvent(of: .value)
        { (listSnapshot) in
         
            let listData = listSnapshot.value as! [String : Any]
            _ = self.AddListWithObserver(id: listId, data: listData)
            
            if let del = self.delegate
            {
                del.NewListAdded()
            }
        }
    }
    
    fileprivate func ListsKeysChildRemoved(_ listKeySnapshot: DataSnapshot)
    {
        let listId = listKeySnapshot.key
        if let listIndex = FindListIndex(listId)
        {
            data.remove(at: listIndex)
            if let del = delegate
            {
                del.ListRemoved()
            }
        }
    }
    
    fileprivate func AddListWithObserver(id: String, data: [String : Any]) -> ListWithObserver
    {
        let newList = List.Deserialize(id: id,
                                       data: data)
        
        let observer = ListWithObserver(list: newList,
                                        listChangedCallback: self.ListChanged)
        
        observer.Activate()
        
        self.data.append(observer)
        
        return observer
    }
    
    fileprivate func ListChanged()
    {
        if let del = delegate
        {
            del.ListUpdated()
        }
    }
    
    fileprivate func FindListIndex(_ id : String) -> Int?
    {
        return data.firstIndex { (listWithObserver) -> Bool in
            return (listWithObserver.list.id == id)
        }
    }
}
