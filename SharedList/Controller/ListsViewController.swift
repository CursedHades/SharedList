//
//  ListsViewController.swift
//  SharedList
//
//  Created by Lukasz on 03/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit
import Firebase

class ListsViewController: UIViewController {

    @IBOutlet var listTitleTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    var lists = [List]()
    
    var selectedListIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "listCell")
        
        AddListsObserver()
    }

    @IBAction func AddListPressed(_ sender: Any) {
        
        if (listTitleTextField.text?.count == 0) {
            print("cannot add list with empty name")
        }
        else {
            
            let dbRef = Database.database().reference()
            
            let newListRef = dbRef.child("lists").childByAutoId()
            let newListKey = newListRef.key!
            
            let itemsRef = dbRef.child("items").childByAutoId()
            let itemsKey = itemsRef.key!
            
            let listTitle = listTitleTextField.text!
            let userId = Auth.auth().currentUser!.uid
            
            let serialized = List.Serialize(title: listTitle, owner_id: userId, items_id: itemsKey)
            let updateData = ["users/\(userId)/lists/\(newListKey)" : true,
                              "lists/\(newListKey)" : serialized,
                              "items/\(itemsKey)/list_id" : newListKey] as [String : Any]
            
            dbRef.updateChildValues(updateData)
            { (error, snapshot) in
                
                if (error != nil) {
                    print(error!)
                }
            }
        }
    }
    
    func RemoveList(index: Int) {
        
        let dbRef = Database.database().reference()
        
        let listId = lists[index].id!
        let itemsId = lists[index].items_id
        let userId = Auth.auth().currentUser!.uid
        
        let updateData = ["users/\(userId)/lists/\(listId)" : NSNull(),
                          "lists/\(listId)" : NSNull(),
                          "items/\(itemsId)" : NSNull()] as [String : Any]
        
        dbRef.updateChildValues(updateData)
    }
    
    func AddListsObserver() {
        
        // Observer set for /users/user_id/lists
        let userId = Auth.auth().currentUser!.uid
        let listsKeyDbRef = Database.database().reference().child("users/\(userId)/lists")
        listsKeyDbRef.observe(.childAdded)
        { (listKeySnapshot) in
            
            let listKey = listKeySnapshot.key
            let listDbRef = Database.database().reference().child("lists/\(listKey)")
            
            // Observer for lists id
            listDbRef.observeSingleEvent(of: .value, with:
            { (listSnapshot) in
                let dict = listSnapshot.value as! [String: String]
                
                let list = List.Deserialize(data: dict)
                list.id = listDbRef.key
                
                self.lists.append(list)
                self.tableView.reloadData()
                
            })
        }
        
        listsKeyDbRef.observe(.childRemoved)
        { (listKeySnapshot) in
            
            for (index, list) in self.lists.enumerated() {
                
                if (list.id! == listKeySnapshot.key) {
                    
                    self.lists.remove(at: index)
                    self.tableView.reloadData()
                    return
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let listIndex = selectedListIndex else { fatalError("No list was selected") }
        
        selectedListIndex = nil
        
        if (segue.identifier == "goToSingleList")
        {
            let singleListVC = segue.destination as! SingleListViewController
            singleListVC.list = lists[listIndex]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let dbRef = Database.database().reference().root
        
        let query = dbRef.child("users").queryOrdered(byChild: "email").queryEqual(toValue: "1@2.com")
        
        query.observeSingleEvent(of: .value) { (snapshot) in
            
        }
    }
}



extension ListsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if lists.count != 0 {
            return lists.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        
        if lists.count != 0 {
            cell.textLabel?.text = lists[indexPath.row].title
        }
        else {
            cell.textLabel?.text = "Add new list"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        do {
//            try Auth.auth().signOut()
//
//            navigationController?.popToRootViewController(animated: true)
//        }
//        catch {
//            print("singing out failed with errror: \(error)")
//        }
//
//        return
        
        RemoveList(index: indexPath.row)
        
//        selectedListIndex = indexPath.row
//        performSegue(withIdentifier: "goToSingleList", sender: self)
    }
}
