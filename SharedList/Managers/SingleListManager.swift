//
//  SingleListManager.swift
//  SharedList
//
//  Created by Lukasz on 22/05/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase

protocol ItemWithObserverDelegate : class
{
    func ItemUpdated()
}

class ItemWithObserver
{
    let item : Item
    
    weak var delegate : ItemWithObserverDelegate?
    
    private let itemsId : String
    private var observer : ChangedObserver?
    private var active : Bool = false
    
    init (item: Item, itemsId: String)
    {
        self.item = item
        self.itemsId = itemsId
    }
    
    func Activate()
    {
        if (active == false)
        {
            let itemDbRef = frb_utils.ItemsDbRef(itemsId).child(Items.Keys.items.rawValue).child(item.id)
            observer = ChangedObserver(dbRef: itemDbRef, dataChangedCallback: Updated(snapshot:))
            observer?.Activate()
            active = true
        }
    }
    
    func Updated(snapshot : DataSnapshot)
    {
        let itemData = [snapshot.key : snapshot.value]
        self.item.Update(data: itemData)
        
        if let del = delegate
        {
            del.ItemUpdated()
        }
    }
}


protocol SingleListManagerDelegate : class {
    
    func DataLoaded()
    func NewItemAdded()
}

class SingleListManager {
    
    weak var delegate : SingleListManagerDelegate? = nil
    
    var itemsCount : Int {
        get { return data.count }
    }
    
    let list : List
    
    fileprivate let frbManager : FirebaseManager
    fileprivate let obsererversManager : ObserversHandler
    fileprivate var observerActive : Bool = false
    fileprivate var data = [ItemWithObserver]()
    
    
    init(list: List, frbManager: FirebaseManager)
    {
        self.list = list
        self.frbManager = frbManager
        
        let itemsDbRef = frb_utils.ItemsDbRef(list.items_id).child(Items.Keys.items.rawValue)
        self.obsererversManager = ObserversHandler(itemsDbRef)
    }
    
    func LoadData()
    {
        let itemsDbRef = frb_utils.ItemsDbRef(list.items_id).child(Items.Keys.items.rawValue)
        itemsDbRef.observeSingleEvent(of: .value)
        { (itemsTableSnapshot) in
            
            if (itemsTableSnapshot.exists() == false)
            {
                if let del = self.delegate {
                    del.DataLoaded()
                }
                return
            }
            
            let itemsIds = (itemsTableSnapshot.value! as! [String : Any]).keys
            var itemsCounter = itemsIds.count
            
            for itemId in itemsIds
            {
                itemsDbRef.child(itemId).observeSingleEvent(of: .value)
                { (itemSnapshot) in
                    
                    let itemDict = itemSnapshot.value! as! [String : Any]
                    self.AddLoadedItem(id: itemId, data: itemDict)
                    
                    itemsCounter = itemsCounter - 1
                    if let del = self.delegate
                    {
                        if (itemsCounter == 0)
                        {
                            del.DataLoaded()
                            self.ActivateObservers()
                        }
                        else
                        {
                            del.NewItemAdded()
                        }
                    }
                }
            }
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
        let dbRef = Database.database().reference()
        let newItemDbRef = frb_utils.ItemsDbRef(list.items_id).child(Items.Keys.items.rawValue).childByAutoId()
        
        let newItem = Item(itemsId: list.items_id,
                           id: newItemDbRef.key!,
                           title: title,
                           done: false,
                           author: "Kociak")
        
        let updateData = newItem.Serialize()
        
        dbRef.updateChildValues(updateData)
        { (error, snapshot) in
            
            if (error != nil) {
                print("New item add failed with error: \(error!)")
            }
        }
    }
    
    func ReverseDone(index : Int)
    {
        let item = data[index].item
        let updateData = [item.Path(Item.Keys.done) : !item.done]
        
        let dbRef = Database.database().reference()
        dbRef.updateChildValues(updateData)
        { (error, snapshot) in
            
            if (error != nil) {
                print("Cant change done property failed with error: \(error!)")
            }
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
    
    fileprivate func AddLoadedItem(id: String, data: [String : Any])
    {
        let newItem = Item.Deserialize(itemsId: list.items_id,
                                       id: id,
                                       data: data)
        
        let observer = ItemWithObserver(item: newItem,
                                        itemsId: list.items_id)
        observer.delegate = self
        observer.Activate()
        
        self.data.append(observer)
    }
    
    fileprivate func ItemsChildAdded(_ itemSnapshot: DataSnapshot)
    {
        let itemId = itemSnapshot.key
        if (FindItem(itemId) != nil)
        {
            return
        }
        
        let itemDict = itemSnapshot.value! as! [String : Any]
        AddLoadedItem(id: itemId, data: itemDict)
        
        if let del = delegate
        {
            del.NewItemAdded()
        }
    }
    
    fileprivate func ItemsChildRemoved(_ itemSnapshot: DataSnapshot)
    {
        fatalError("not yet implemented")
    }
    
    fileprivate func FindItem(_ id: String) -> Item?
    {
        for item in data
        {
            if (item.item.id == id)
            {
                return item.item
            }
        }
        return nil
    }
}

extension SingleListManager : ItemWithObserverDelegate
{
    func ItemUpdated()
    {
        if let del = delegate
        {
            del.DataLoaded()
        }
    }
}
