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

    @IBOutlet var listNameTextField: UITextField!
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
        
        if (listNameTextField.text?.count == 0) {
            print("cannot add list with empty name")
        }
        else {
            let newList = List()
            newList.name = listNameTextField.text!
            
            let userID = Auth.auth().currentUser!.uid
            let dbRef = Database.database().reference().root
            
            // Saving list with new auto Id
            let listRef = dbRef.child("lists").childByAutoId()
            listRef.setValue(["name": newList.name])
            
            // Saving userId for list
            listRef.child("users").setValue([userID : 1])
            
            // Saving list for user
            dbRef.child("users").child(userID).child("lists").child(listRef.key!).setValue(1)
            
            tableView.reloadData()
        }
    }
    
    func AddListsObserver() {
        
        let listsDbRef = Database.database().reference().child("lists")
        
        listsDbRef.observe(.childAdded)
        { (snapshot) in
            
            let listKey = snapshot.key
            
            listsDbRef.child("\(listKey)/name").observeSingleEvent(of: .value, with:
                { (snapshot2) in
                    let list = List()
                    list.name = snapshot2.value as! String
                    list.dbReference = listsDbRef.child("\(listKey)")
                    
                    self.lists.append(list)
                    
                    self.tableView.reloadData()
            })
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
            cell.textLabel?.text = lists[indexPath.row].name
        }
        else {
            cell.textLabel?.text = "Add new list"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedListIndex = indexPath.row
        performSegue(withIdentifier: "goToSingleList", sender: self)
    }
}
