//
//  ListsViewController.swift
//  SharedList
//
//  Created by Lukasz on 03/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit

class ListsViewController: UIViewController {

    @IBOutlet var listTitleTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    var selectedListIndex : Int?
    
    var listManager : ListManager? {
        
        didSet {
            listManager?.delegate = self
            listManager?.ActivateObservers()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "listCell")
    }

    @IBAction func AddListPressed(_ sender: Any) {
        
        if (listTitleTextField.text?.count == 0) {
            print("cannot add list with empty name")
        }
        else {
            let listTitle = listTitleTextField.text!
            listManager!.AddNewList(title: listTitle)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let listIndex = selectedListIndex else { fatalError("No list was selected") }
        
        selectedListIndex = nil
        
        if (segue.identifier == "goToSingleList")
        {
            let singleListVC = segue.destination as! SingleListViewController
            singleListVC.list = listManager!.lists[listIndex]
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//
//        let dbRef = Database.database().reference().root
//
//        let query = dbRef.child("users").queryOrdered(byChild: "email").queryEqual(toValue: "1@2.com")
//
//        query.observeSingleEvent(of: .value) { (snapshot) in
//
//        }
//    }
}



extension ListsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if listManager!.lists.count != 0 {
            return listManager!.lists.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        
        if listManager!.lists.count != 0 {
            cell.textLabel?.text = listManager!.lists[indexPath.row].title
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
        
//        firebaseManager.RemoveList(index: indexPath.row)
        
        selectedListIndex = indexPath.row
        performSegue(withIdentifier: "goToSingleList", sender: self)
    }
}

extension ListsViewController : ListManagerDelegate {
    
    func NewListAdded() {
        
        tableView.reloadData()
    }
    
    func ListRemoved() {
        
        tableView.reloadData()
    }
}
