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
}

class ListManager {
    
    weak var delegate : ListManagerDelegate? = nil
    
    var lists = [List]()
    
    var observers = [DataEventType: DatabaseHandle?]()
    fileprivate var activeObservers = 0
    
    func LoadData() {
        
        let userId = Auth.auth().currentUser!.uid
        let userListsDbRef = Database.database().reference().child("users/\(userId)/lists")
        
        let query = userListsDbRef.queryOrderedByKey()
        
        query.observeSingleEvent(of: .value)
        { (listsSnapshot) in
            
            let listsIds = (listsSnapshot.value! as! [String : Any]).keys
            var listsCounter = listsIds.count
            
            for (listId) in listsIds {
                
                let listDbRef = Database.database().reference().child("lists/\(listId)")
                listDbRef.observeSingleEvent(of: .value, with: { (listSnapshot) in
                    
                    let newList = List.Deserialize(id: listId, data: listSnapshot.value as! [String : String])
                    self.lists.append(newList)
                    
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
            
            let userId = Auth.auth().currentUser!.uid
            let userListsDbRef = Database.database().reference().child("users/\(userId)/lists")
            
            observers[.childAdded] = userListsDbRef.observe(.childAdded)
            { (listKeySnapshot) in
                
                for list in self.lists {
                    if (list.id == listKeySnapshot.key) {
                        return
                    }
                }
                
                let listDbRef = Database.database().reference().child("lists/\(listKeySnapshot.key)")
                listDbRef.observeSingleEvent(of: .value, with: { (listSnapshot) in
                    
                    let newList = List.Deserialize(id: listKeySnapshot.key, data: listSnapshot.value as! [String: String])
                    
                    self.lists.append(newList)
                    
                    if let del = self.delegate {
                        del.NewListAdded()
                    }
                })
            }
        }
        
        if (observers[.childRemoved] == nil) {
            
            let userId = Auth.auth().currentUser!.uid
            let listsKeyDbRef = Database.database().reference().child("users/\(userId)/lists")
            observers[.childRemoved] = listsKeyDbRef.observe(.childRemoved)
            { (listKeySnapshot) in
                
                for (index, list) in self.lists.enumerated() {
                    
                    if (list.id == listKeySnapshot.key) {
                        
                        self.lists.remove(at: index)
                        
                        if let del = self.delegate {
                            del.ListRemoved()
                        }
                        return
                    }
                }
            }
        }
    }
    
    func DeactivateObservers()
    {
        if (activeObservers == 0) { fatalError("No active observers.") }
        
        activeObservers = activeObservers - 1
        
        if (activeObservers == 0) {
            
            let userId = Auth.auth().currentUser!.uid
            let listsKeyDbRef = Database.database().reference().child("users/\(userId)/lists")
         
            listsKeyDbRef.removeAllObservers()
            observers.removeAll()
        }
    }
    
    func AddNewList(title: String) {
        
        let dbRef = Database.database().reference()
        
        let newListRef = dbRef.child("lists").childByAutoId()
        let newListKey = newListRef.key!
        
        let newItemsRef = dbRef.child("items").childByAutoId()
        let newItemsKey = newItemsRef.key!
        
        let userId = Auth.auth().currentUser!.uid
        
        let serializedList = List.Serialize(title: title, owner_id: userId, items_id: newItemsKey)
        
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
        
        if (lists.count > index)
        {
            let dbRef = Database.database().reference()
            
            let listId = lists[index].id
            let itemsId = lists[index].items_id
            let userId = Auth.auth().currentUser!.uid
            
            let updateData = ["users/\(userId)/lists/\(listId)" : NSNull(),
                              "lists/\(listId)" : NSNull(),
                              "items/\(itemsId)" : NSNull()] as [String : Any]
            
            dbRef.updateChildValues(updateData)
        }
    }
    
    func GetListById(_ id: String, completionHandler: @escaping (_ list: List?) -> Void) {
        
        let listDbRef = Database.database().reference().child("lists/\(id)")
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
}
