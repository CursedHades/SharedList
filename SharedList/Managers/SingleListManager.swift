//
//  SingleListManager.swift
//  SharedList
//
//  Created by Lukasz on 22/05/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase

class ItemWithObserver
{
    let item : Item
    
    private let itemUpdatedCallback : (Item) -> Void
    private var observer : ChangedObserver? = nil
    
    init (item: Item, itemUpdatedCallback: @escaping (Item) -> Void)
    {
        self.item = item
        self.itemUpdatedCallback = itemUpdatedCallback
    }
    
    func Activate()
    {
        if (observer == nil)
        {
            let itemDbRef = frb_utils.ItemsDbRef(item.itemsId).child(Items.Keys.items.rawValue).child(item.id)
            
            observer = ChangedObserver(dbRef: itemDbRef, dataChangedCallback: Updated(snapshot:))
            observer?.Activate()
        }
    }
    
    private func Updated(snapshot : DataSnapshot)
    {
        let itemData = [snapshot.key : snapshot.value]
        self.item.Update(data: itemData)
        
        self.itemUpdatedCallback(self.item)
    }
}


protocol SingleListManagerDelegate : class {
    
    func ItemLoaded()
    func AllItemsLoaded()
    func ItemChanged()
    func ItemRemoved()
}


class SingleListManager {
    
    weak var delegate : SingleListManagerDelegate? = nil
    
    var itemsCount : Int {
        get { return data.count }
    }
    
    let list : List
    
    fileprivate let authManager : AuthManager
    fileprivate let obsererversManager : ObserversHandler
    fileprivate var observerActive : Bool = false
    fileprivate var data = [ItemWithObserver]()
    
    fileprivate var loadingData : Bool = false
    fileprivate var itemPrefetchCount : Int = 0
    
    
    init(list: List, authManager: AuthManager)
    {
        self.list = list
        self.authManager = authManager
        
        let itemsDbRef = frb_utils.ItemsDbRef(list.items_id).child(Items.Keys.items.rawValue)
        self.obsererversManager = ObserversHandler(itemsDbRef)
    }
    
    func LoadData()
    {
        loadingData = true
        
        let itemsDbRef = frb_utils.ItemsDbRef(list.items_id).child(Items.Keys.items.rawValue)
        itemsDbRef.observeSingleEvent(of: .value)
        { (itemsTableSnapshot) in
            
            if (itemsTableSnapshot.exists() == false)
            {
                if let del = self.delegate
                {
                    del.AllItemsLoaded()
                    self.ActivateObservers()
                    self.loadingData = false
                }
                return
            }
            
            self.itemPrefetchCount = Int(itemsTableSnapshot.childrenCount)
            self.ActivateObservers()
        }
    }
    
    func GetItem(_ idx : Int) -> Item?
    {
        if (idx < itemsCount)
        {
            return data[idx].item
        }
        return nil
    }
    
    func AddNewItem(title : String)
    {
        let newItemDbRef = frb_utils.ItemsDbRef(list.items_id).child(Items.Keys.items.rawValue).childByAutoId()
        let authorId = authManager.currentUser!.id
        
        let updateData = Item.Serialize(itemsId: list.items_id,
                                        id: newItemDbRef.key!,
                                        title: title,
                                        checked: false,
                                        authorId: authorId,
                                        doneById: "NONE")
        
        frb_utils.DbRef().updateChildValues(updateData)
        { (error, snapshot) in
            
            if (error != nil) {
                print("New item add failed with error: \(error!)")
            }
        }
    }
    
    func RemoveChecked()
    {
        for item in data
        {
            if item.item.checked
            {
                RemoveItem(item.item)
            }
        }
    }
    
    func RemoveItem(index: Int)
    {
        let item = data[index].item
        RemoveItem(item)
    }
    
    func ReverseChecked(index : Int)
    {
        let item = data[index].item
        let newChecked = !item.checked
        let checkedByValue = newChecked ? authManager.currentUser!.id
                                        : "NONE"
        
        let updateData = [item.PathForKey(Item.Keys.checked) : newChecked,
                          item.PathForKey(Item.Keys.checked_by_id) : checkedByValue] as [String : Any]
        
        let dbRef = Database.database().reference()
        dbRef.updateChildValues(updateData)
        { (error, snapshot) in
            
            if (error != nil) {
                print("Cant change done property failed with error: \(error!)")
            }
        }
    }
    
    fileprivate func RemoveItem(_ item: Item)
    {
        let dbRef = frb_utils.ItemDbRef(item.itemsId, item.id)
        
        dbRef.removeValue()
        { (error, ref) in

            if (error != nil)
            {
                print("Item removal failed with error: \(error!)")
            }
            
            print("item: '\(item.title)' removed!")
        }
    }
    
    fileprivate func ActivateObservers()
    {
        if (observerActive == false)
        {
            obsererversManager.AddObserver(eventType: .childAdded, ItemsChildAdded)
            obsererversManager.AddObserver(eventType: .childRemoved, ItemsChildRemoved)
            
            observerActive = true
        }
    }
    
    fileprivate func AddLoadedItem(id: String, data: [String : Any], completion:(()->Void)?)
    {
        let newItem = self.AddItemWithObserver(id: id, data: data)
        
        LoadUserNames(item: newItem.item)
        {
            completion?()
        }
    }
    
    fileprivate func LoadUserNames(item: Item, completion:(()-> Void)?)
    {
        let usersDbRef = frb_utils.ListUsersDbRef(list.id)
        usersDbRef.observeSingleEvent(of: .value)
        { (usersSnapshot) in
            
            let usersData = usersSnapshot.value! as! [String : Any]
            if let authorName = usersData[item.authorId]
            {
                item.UpdateAuthorName(authorName as! String)
            }
            if let checkedByName = usersData[item.checkedById]
            {
                item.UpdateCheckedByName(checkedByName as! String)
            }
            
            completion?()
        }
    }
    
    fileprivate func AddItemWithObserver(id: String, data: [String : Any]) -> ItemWithObserver
    {
        let newItem = Item.Deserialize(itemsId: self.list.items_id,
                                       id: id,
                                       data: data)
        
        let observer = ItemWithObserver(item: newItem,
                                        itemUpdatedCallback: self.ItemChanged)
        
        observer.Activate()
        
        self.data.append(observer)
        
        return observer
    }
    
    fileprivate func ItemChanged(item: Item)
    {
        LoadUserNames(item: item)
        {
            if let del = self.delegate
            {
                del.ItemChanged()
            }
        }
    }

    fileprivate func ItemsChildAdded(_ itemSnapshot: DataSnapshot)
    {
        let itemId = itemSnapshot.key
        if (FindItemIndex(itemId) != nil)
        {
            return
        }
        
        let itemDict = itemSnapshot.value! as! [String : Any]
        
        AddLoadedItem(id: itemId, data: itemDict)
        {
            if let del = self.delegate
            {
                del.ItemLoaded()
                
                if self.loadingData == true
                {
                    self.itemPrefetchCount = self.itemPrefetchCount - 1
                    if self.itemPrefetchCount == 0
                    {
                        self.loadingData = false
                        del.AllItemsLoaded()
                    }
                }
                
            }
        }
    }
    
    fileprivate func ItemsChildRemoved(_ itemSnapshot: DataSnapshot)
    {
        let itemId = itemSnapshot.key
        if let itemIndex = FindItemIndex(itemId)
        {
            data.remove(at: itemIndex)
            if let del = delegate
            {
                del.ItemRemoved()
            }
        }
    }
    
    fileprivate func FindItemIndex(_ id: String) -> Int?
    {
        return data.firstIndex { (itemWithObserver) -> Bool in
            return (itemWithObserver.item.id == id)
        }
    }
}
