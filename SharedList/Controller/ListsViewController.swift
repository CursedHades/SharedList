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
    
    var lists : [List]?
    
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
        
    }
}

extension ListsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let count = lists?.count {
            return count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        
        if let list = lists?[indexPath.row] {
            cell.textLabel?.text = list.name
        }
        else {
            cell.textLabel?.text = "Add new list."
        }
        
        return cell
    }
    
    
    
}
