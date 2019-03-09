//
//  SingleListViewController.swift
//  SharedList
//
//  Created by Lukasz on 03/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit
import Firebase

class SingleListViewController: UIViewController {
    
    @IBOutlet var newItemTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    var list : List? {
        didSet {
            AddListObservers()
        }
    }
    
    var items = [Item]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "singleListTableViewCell")
    }
    
    func AddItemsObserver(itemsId : String) {
        
        let itemsListDbRef = Database.database().reference().child("items/\(itemsId)")
        
        itemsListDbRef.observe(.childAdded, with: { (itemSnapshot) in
            
            let itemDict = itemSnapshot.value as! [String: String]
            let newItem = Item.Deserialize(data: itemDict)
            newItem.dbRef = itemSnapshot.ref
            
            self.items.append(newItem)
            self.tableView.reloadData()
        })
    }
    
    
    func AddListObservers() {
        
        guard let _ = list else { fatalError("list not set") }
        
        let listRef = list!.dbRef!
        
        listRef.observeSingleEvent(of: .value) {
            (snapshot) in
            if (snapshot.hasChild(List.Keys.items_id.rawValue)) {
                
                let dict = snapshot.value as! [String: String]
                let itemsId = dict[List.Keys.items_id.rawValue]!
                
                self.AddItemsObserver(itemsId: itemsId)
            }
        }
    }
    
    
    @IBAction func AddItemPressed(_ sender: UIButton) {
        
        guard let _ = list else { fatalError("list not set") }
        
        if (newItemTextField.text?.count == 0) {
            print("empty new item text field")
            return
        }
        
        let listRef = list!.dbRef!
        
        listRef.observeSingleEvent(of: .value) {
            (snapshot) in
            if (snapshot.hasChild(List.Keys.items_id.rawValue)) {
                
                let dict = snapshot.value as! [String: String]
                let itemsId = dict[List.Keys.items_id.rawValue]!
                let itemsListDbRef = Database.database().reference().child("items/\(itemsId)")
                
                let itemTitle = self.newItemTextField.text!
                self.AddItemToItemsList(title: itemTitle, itemsDbRef: itemsListDbRef)
            }
            else {
                // New item list created using auto_id
                let itemsDbRef = Database.database().reference().child("items").childByAutoId()
                
                listRef.child(List.Keys.items_id.rawValue).setValue(itemsDbRef.key!)
                
                let itemTitle = self.newItemTextField.text!
                self.AddItemToItemsList(title: itemTitle, itemsDbRef: itemsDbRef)
                
                self.AddItemsObserver(itemsId: itemsDbRef.key!)
            }
        }
    }
    
    func AddItemToItemsList(title: String, itemsDbRef: DatabaseReference) {
        let itemDbRef = itemsDbRef.childByAutoId()
        
        let itemDict = Item.Serialize(title: title)
        itemDbRef.setValue(itemDict) { (error, sth) in
            //TODO: handle error
        }
    }
}


extension SingleListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (items.count != 0){
            return items.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "singleListTableViewCell")
        
        if (items.count != 0) {
            cell?.textLabel?.text = items[indexPath.row].title
        }
        else {
            cell?.textLabel?.text = "Add items"
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let ref = items[indexPath.row].dbRef else {
            fatalError("Failed to get reference to object selected for deletion.")
        }
        
        ref.removeValue(completionBlock:
        { (error, snapshot) in
            if (error != nil) {
                print ("Deleting item failed: \(error!)")
            }
        })
    }
}
