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
            
            let lists = (listsSnapshot.value! as! [String : Int])
            var listsCounter = lists.keys.count

            for (listId, listPosition) in lists
            {
                let listDbRef = frb_utils.ListDbRef(listId)
                listDbRef.observeSingleEvent(of: .value)
                { (listSnapshot) in
                    
                    let listData = listSnapshot.value! as! [String : Any]
                    _ = self.AddListWithObserver(id: listId,
                                                 position: listPosition,
                                                 data: listData)
                    
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
        
        let counter = data.count
        
        var serializedList = List.Serialize(title: title,
                                            owner_id: userId,
                                            items_id: newItemsKey,
                                            creationDate: creationDate)
        
        serializedList["users"] = ["\(userId)" : authManager.currentUser?.name]
        
        let updateData = ["users/\(userId)/lists/\(newListKey)" : counter,
                          "lists/\(newListKey)" : serializedList,
                          "items/\(newItemsKey)/list_id" : newListKey] as [String : Any]
        
        frb_utils.DbRef().updateChildValues(updateData)
        { (error, snapshot) in
            
            if (error != nil) {
                print("New list add failed with error: \(error!)")
            }
        }
    }
    
    func ChangePosition(from: Int, to: Int)
    {
        if (from < 0 || from > data.count - 1 || to < 0 || to > data.count - 1)
        {
            print("Position out of range. From:\(from), To:\(to)")
            return;
        }
        
        let movingList = data.remove(at: from)
        data.insert(movingList, at: to)
        
        var updateData = Dictionary<String, Int>()
        for (pos, list) in data.enumerated()
        {
            list.list.position = pos
            updateData[list.list.id] = pos
        }
        
        frb_utils.UserListsDbRef().updateChildValues(updateData)
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
                let list = List.Deserialize(id: id,
                                            position: -1,
                                            data: listData)
                completionHandler(list)
            }
            else {
                completionHandler(nil)
            }
        }
    }
    
    func AddCurrentUserToList(list: List, completion: @escaping() -> Void)
    {
        let counter = data.count
        
        let userId = authManager.currentUser!.id
        let updateData = [frb_utils.UserInListPath(listId: list.id, userId: userId) : authManager.currentUser!.name,
                          frb_utils.ListInUserListsPath(userId: userId, listId: list.id) : counter] as [String : Any]
        
        frb_utils.DbRef().updateChildValues(updateData)
        { (error, dbRef) in
            completion()
        }
    }
    
    func SortListByPosition()
    {
        data = data.sorted(by: {$0.list.position < $1.list.position})
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
        let listPosition = listKeySnapshot.value as! Int
        if (FindListIndex(listId) != nil)
        {
            return
        }
        
        let listDbRef = frb_utils.ListDbRef(listId)
        listDbRef.observeSingleEvent(of: .value)
        { (listSnapshot) in
         
            let listData = listSnapshot.value as! [String : Any]
            _ = self.AddListWithObserver(id: listId,
                                         position: listPosition,
                                         data: listData)
            
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
    
    fileprivate func AddListWithObserver(id: String, position: Int, data: [String : Any]) -> ListWithObserver
    {
        let newList = List.Deserialize(id: id,
                                       position: position,
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
