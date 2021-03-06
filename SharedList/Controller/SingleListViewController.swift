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
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var newItemNameTextField: UITextField!
    @IBOutlet var detailButton: UIButton!
    
    var listManager : SingleListManager?
    {
        didSet
        {
            listManager?.delegate = self
        }
    }
    
    fileprivate var dataLoading : Bool = false
    fileprivate var dispalDetails : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        self.title = listManager?.list.title
        
        newItemNameTextField.keyboardType = .default
        newItemNameTextField.returnKeyType = .done
        newItemNameTextField.delegate = self
        
        listManager?.LoadData()
        SVProgressHUD.show(withStatus: "Loading data...")
        UpdateUI(enable: false)
        dataLoading = true
        
        let tapper = UITapGestureRecognizer(target: self, action: Selector(("DismissKeyboard")))
        tapper.delegate = self
        view.addGestureRecognizer(tapper)
    }
    
    @objc fileprivate func DismissKeyboard()
    {
        if (self.newItemNameTextField.isFirstResponder)
        {
            view.endEditing(true)
        }
    }
    
    fileprivate func UpdateUI(enable: Bool)
    {
        if (enable)
        {
            newItemNameTextField.isEnabled = true
            tableView.allowsSelection = true
        }
        else
        {
            newItemNameTextField.isEnabled = false
            tableView.allowsSelection = false
        }
    }
    
    fileprivate func AddItem(title: String)
    {
        if let manager = listManager
        {
            manager.AddNewItem(title: title)
        }
    }
    
    @IBAction func DetailsButtonPressed(_ sender: Any)
    {
        self.dispalDetails = !self.dispalDetails
        tableView.reloadData()
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
        
        if let item = listManager?.GetItem(indexPath.row)
        {
            cell?.textLabel?.text = item.title
            cell?.detailTextLabel?.text = PrepareDetailedText(item: item)
            UpdateCellFontColor(cell: cell!, checked: item.checked)
        }
        else
        {
            cell?.textLabel?.text = "Add items"
            cell?.detailTextLabel?.text = ""
        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let item = listManager?.GetItem(indexPath.row)
        {
            if item.checked == true
            {
                // TODO: show popup if you really wanna change done property
                let title = item.title
                let message = "Do you want to ucheck it?"
                let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal)
                
                let buttonYes = DefaultButton(title: "Yes")
                {
                    self.listManager?.ReverseChecked(index: indexPath.row)
                }
                let buttonCancel = CancelButton(title: "No") {
                    
                }
                popup.addButtons([buttonCancel, buttonYes])
                self.present(popup, animated: true, completion: nil)
            }
            else
            {
                listManager?.ReverseChecked(index: indexPath.row)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    fileprivate func PrepareDetailedText(item: Item) -> String
    {
        if (dispalDetails == false)
        {
            return ""
        }
        
        var text = "add: \(item.authorName)"
        if (item.checked == true)
        {
            text += " | check: \(item.checkedByName)"
        }
        return text
    }
    
    fileprivate func UpdateCellFontColor(cell: UITableViewCell, checked: Bool)
    {
        if (checked == true)
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

extension SingleListViewController : UITextFieldDelegate
{
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.detailButton.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        self.detailButton.isHidden = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if let newItem = CorrectInput(textField.text)
        {
            self.AddItem(title: newItem)
            self.view.endEditing(true)
            textField.text = ""
            return true
        }
        return false
    }
    
    private func CorrectInput(_ itemName : String?) -> String?
    {
        if let str = itemName
        {
            let newStr = str.trimmingCharacters(in: .whitespacesAndNewlines)
            return (newStr != "" ? newStr : nil)
        }
        return nil
    }
}

extension SingleListViewController : UIGestureRecognizerDelegate
{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        return self.newItemNameTextField.isFirstResponder
    }
}
