//
//  SingleListViewController.swift
//  SharedList
//
//  Created by Lukasz on 03/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit
import PopupDialog
import SVProgressHUD

class SingleListViewController: UIViewController {
    
    @IBOutlet var newItemTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var addItemButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    
    var listManager : SingleListManager?
    {
        didSet
        {
            listManager?.delegate = self
        }
    }
    
    fileprivate var dataLoading : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        self.title = listManager?.list.title
        
        listManager?.LoadData()
        SVProgressHUD.show(withStatus: "Loading data...")
        UpdateUI(enable: false)
        dataLoading = true
    }
    
    @IBAction func AddItemPressed(_ sender: UIButton)
    {
        let title = self.newItemTextField.text!
        
        if let manager = listManager
        {
            manager.AddNewItem(title: title)
        }
    }
    
    @IBAction func ShareButtonPressed(_ sender: UIButton) {

//        let title = "title"
//        let message = "message"
//
//        let popup = PopupDialog(title: title, message: message)
//
//        let cancelButton = CancelButton(title: "cancel") {}
//
//        let shareButton = DefaultButton(title: "share") {
//            self.frbManager?.invitationManager.SendInvitation(destinationUserEmail: "1@2.com",
//                                                              listId: self.list!.id,
//                                                              message: "message")
//        }
//
//        popup.addButtons([shareButton, cancelButton])
//
//        self.present(popup, animated: true, completion: nil)
    }
    
    
    fileprivate func UpdateUI(enable: Bool)
    {
        if (enable)
        {
            newItemTextField.isEnabled = true
            addItemButton.isEnabled = true
            shareButton.isEnabled = true
            
            tableView.allowsSelection = true
        }
        else
        {
            newItemTextField.isEnabled = false
            addItemButton.isEnabled = false
            shareButton.isEnabled = false
            
            tableView.allowsSelection = false
        }
    }
}

extension SingleListViewController : SingleListManagerDelegate
{
    func DataLoaded()
    {
        tableView.reloadData()
        
        if (dataLoading)
        {
            SVProgressHUD.showSuccess(withStatus: "Awsome!")
            SVProgressHUD.dismiss(withDelay: 0.6)
            {
                self.UpdateUI(enable: true)
            }
            dataLoading = false
        }
    }
    
    func NewItemAdded()
    {
        tableView.reloadData()
    }
    
    func ItemRemoved()
    {
        tableView.reloadData()
    }
}

extension SingleListViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let itemsCount = listManager?.itemsCount
        {
            if (itemsCount > 0)
            {
                return itemsCount
            }
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell")
        if let itemsCount = listManager?.itemsCount
        {
            if (itemsCount > 0)
            {
                if let item = listManager?.GetItem(indexPath.row)
                {
                    cell?.textLabel?.text = item.title
                    cell?.detailTextLabel?.text = "+: \(item.authorName)"
                    UpdateCell(cell: cell!, done: item.done)
                    
                    return cell!
                }
            }
        }
        
        cell?.textLabel?.text = "Add items"
        cell?.detailTextLabel?.text = ""
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let manager = listManager
        {
            manager.ReverseDone(index: indexPath.row)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    fileprivate func UpdateCell(cell: UITableViewCell, done: Bool)
    {
        if (done == true)
        {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.lightGray
            cell.detailTextLabel?.textColor = UIColor.lightGray
        }
        else
        {
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        }
    }
}
