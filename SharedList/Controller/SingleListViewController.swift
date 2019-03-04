//
//  SingleListViewController.swift
//  SharedList
//
//  Created by Lukasz on 03/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit

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
    
    
    func AddListObservers() {
        
        guard let itemsDbRef = list?.dbReference?.child("items") else { fatalError("Cannot ref to items") }
        
        itemsDbRef.observe(.childAdded)
        { (snapshot) in
            
            let newItem = Item()
            newItem.name = snapshot.key
            newItem.dbReference = snapshot.ref
            
            self.items.append(newItem)
            
            self.tableView.reloadData()
        }
        
        itemsDbRef.observe(.childRemoved)
        { (snapshot) in
            
            for (index, item) in self.items.enumerated() {
                if (item.name == snapshot.key) {
                    self.items.remove(at: index)
                    break
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func AddItemPressed(_ sender: UIButton) {
        
        guard let _ = list else { fatalError("list not set") }
        
        if (newItemTextField.text?.count == 0) {
            print("empty new item text field")
            return
        }
        
        let itemName = newItemTextField.text!
        let listRef = list!.dbReference!
        
        listRef.child("items").child(itemName).setValue(1)
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
            cell?.textLabel?.text = items[indexPath.row].name
        }
        else {
            cell?.textLabel?.text = "Add items"
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let ref = items[indexPath.row].dbReference else {
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