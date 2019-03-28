//
//  SingleListViewController.swift
//  SharedList
//
//  Created by Lukasz on 03/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit
import Firebase
import PopupDialog

class SingleListViewController: UIViewController {
    
    @IBOutlet var newItemTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    var list : List? {
        didSet {
            AddObservers()
        }
    }
    
    var items = [Item]()
    
    var frbManager : FirebaseManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "singleListTableViewCell")
        
        self.title = list?.title
    }
    
    func AddObservers() {
        
        guard let _ = list else { fatalError("list not set") }
        guard let _ = list?.id else {fatalError("list without id") }
        
        AddItemsObserver(itemsId: list!.items_id)
    }
    
    func AddItemsObserver(itemsId : String) {
        
        let itemsDbRef = Database.database().reference().child("items/\(itemsId)")
        
        itemsDbRef.observe(.childAdded, with: { (itemSnapshot) in
            
            if (itemSnapshot.key != "list_id")
            {
                let itemDict = itemSnapshot.value as! [String: String]
                let newItem = Item.Deserialize(data: itemDict)
                newItem.id = itemSnapshot.key
                
                self.items.append(newItem)
                self.tableView.reloadData()
            }
        })
        
        itemsDbRef.observe(.childRemoved)
        { (snapshot) in
            
            let title = (snapshot.value as! [String : String])[Item.Keys.title.rawValue]
            for (index, item) in self.items.enumerated() {
                
                if (item.title == title)
                {
                    self.items.remove(at: index)
                    self.tableView.reloadData()
                    return
                }
            }
        }
    }
    
    
    @IBAction func AddItemPressed(_ sender: UIButton) {
        
        guard let _ = list else { fatalError("list not set") }
        
        if (newItemTextField.text?.count == 0) {
            print("empty new item text field")
            return
        }
        
        let itemTitle = self.newItemTextField.text!
        self.AddItemToItemsList(title: itemTitle, itemsId: list!.items_id)
    }
    
    func AddItemToItemsList(title: String, itemsId: String) {
        
        let itemDict = Item.Serialize(title: title)
        let itemDbRef = Database.database().reference().child("items/\(itemsId)").childByAutoId()
        
        itemDbRef.setValue(itemDict) { (error, sth) in
            //TODO: handle error
        }
    }
    
    func RemoveItem(Index: Int) {
        
        let item = items[Index]
        
        let itemRef = Database.database().reference().child("items/\(list!.items_id)/\(item.id!)")
        
        itemRef.removeValue { (error, snapshot) in
            if (error != nil) {
                print(("Item removing failed with error: \(error!)"))
            }
        }
    }
    
    @IBAction func ShareButtonPressed(_ sender: UIButton) {

        let title = "title"
        let message = "message"
        
        let popup = PopupDialog(title: title, message: message)
        
        let cancelButton = CancelButton(title: "cancel") {}
        
        let shareButton = DefaultButton(title: "share") {
            self.frbManager?.proposalManager.SendProposal(destinationUserEmail: "1@2.com",
                                                          listId: self.list!.id,
                                                          message: "message")
        }
        
        popup.addButtons([shareButton, cancelButton])
        
        self.present(popup, animated: true, completion: nil)
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
    
        RemoveItem(Index: indexPath.row)
    }
}
