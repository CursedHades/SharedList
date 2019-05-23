//
//  SingleListManager.swift
//  SharedList
//
//  Created by Lukasz on 22/05/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase

class ItemWithObserver {
    var item : Item
    var observer : ChangedObserver
    
    init (item: Item) {
        self.item = item
        observer = ChangedObserver(dbRef: DatabaseReference())
    }
}

extension ItemWithObserver : ChangedObserverDelegate {
    
    func DataChanged(data: [String : Any?]) {
        fatalError("Not yet implemented")
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
    
    fileprivate let frbManager : FirebaseManager
    fileprivate let list : List
    
    fileprivate var data = [ItemWithObserver]()
    
    init(list: List, frbManager: FirebaseManager)
    {
        self.list = list
        self.frbManager = frbManager
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
    
    fileprivate func AddLoadedItem(id: String, data: [String : Any])
    {
        let newItem = Item.Deserialize(id: id, data: data)
        let observer = ItemWithObserver(item: newItem)
//        observer.delegate = self
        self.data.append(observer)
    }
}
