//
//  ListsViewController.swift
//  SharedList
//
//  Created by Lukasz on 03/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit

class ListsViewController: UIViewController {

    @IBOutlet var listNameTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    var lists = [List]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "listCell")
        
        // Template code for testing tableView code
//        lists = [List]()
//        let list = List()
//        list.name = "one"
//        lists?.append(list)
//        list.name = "two"
//        lists?.append(list)
//        list.name = "three"
//        lists?.append(list)
    }

    @IBAction func AddListPressed(_ sender: Any) {
        
        if (listNameTextField.text?.count == 0) {
            print("cannot add list with empty name")
        }
        else {
            let newList = List()
            newList.name = listNameTextField.text!
            
            lists.append(newList)
            
            tableView.reloadData()
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
    
    
    
}
