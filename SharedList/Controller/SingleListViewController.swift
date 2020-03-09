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
    
    @IBOutlet var bottomBarContainer: UIView!
    @IBOutlet var newItemInputContainer: UIView!
    @IBOutlet var bottomMenuContainer: UIView!
    
    @IBOutlet var addItemButton: UIButton!
    @IBOutlet var detailItemsButton: UIButton!
    @IBOutlet var removeItemsButton: UIButton!
    
    fileprivate var bottomMenuVisible: Bool = true
    
    var listManager : SingleListManager?
    {
        didSet
        {
            listManager?.delegate = self
        }
    }
    
    fileprivate var dataLoading : Bool = false
    fileprivate var displayDetails : Bool = false
    fileprivate var displayEdit : Bool = false
    
    fileprivate var awaitenNotifations : Int = 0
    fileprivate var itemsToRemove : Int = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        self.title = listManager?.list.title
        
        vc_utils.SetupKeyboard(textField: newItemNameTextField)
        newItemNameTextField.delegate = self
        
        listManager?.LoadData()
        SVProgressHUD.show(withStatus: "Loading data...")
        UpdateUI(enable: false)
        dataLoading = true
        
        let tapper = UITapGestureRecognizer(target: self,
                                            action: #selector(SingleListViewController.DismissKeyboard))
        tapper.delegate = self
        view.addGestureRecognizer(tapper)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SingleListViewController.KeyboardDismissed),
                                               name: UIResponder.keyboardDidHideNotification,
                                               object: nil)
    }
    
    @objc fileprivate func DismissKeyboard()
    {
        if (self.newItemNameTextField.isFirstResponder)
        {
            view.endEditing(true)
        }
    }
    
    @objc fileprivate func KeyboardDismissed()
    {
        SwitchBottomContainer(duration: 0.1)
    }
    
    fileprivate func UpdateBottomBar()
    {
        ui_utils.SetSfSymbolButton(button: addItemButton,
                                   icon: .Add,
                                   selected: false,
                                   traitCollection: self.traitCollection)
        
        ui_utils.SetSfSymbolButton(button: detailItemsButton,
                                   icon: .Details,
                                   selected: displayDetails,
                                   traitCollection: self.traitCollection)
        
        ui_utils.SetSfSymbolButton(button: removeItemsButton,
                                   icon: .Remove,
                                   selected: displayEdit,
                                   traitCollection: self.traitCollection)
        
    }
    
    fileprivate func UpdateUI(enable: Bool)
    {
        
        bottomBarContainer.backgroundColor = ui_utils.GetBottomBarColour()
        
        UpdateBottomBar()
        
        if (enable)
        {
            tableView.allowsSelection = true
            
            newItemNameTextField.isEnabled = true
            addItemButton.isEnabled = true
            detailItemsButton.isEnabled = true
            removeItemsButton.isEnabled = true
        }
        else
        {
            tableView.allowsSelection = false
            
            newItemNameTextField.isEnabled = false
            addItemButton.isEnabled = false
            detailItemsButton.isEnabled = false
            removeItemsButton.isEnabled = false
        }
    }
    
    fileprivate func SwitchBottomContainer(duration: TimeInterval)
    {
        let currentView = bottomMenuVisible ? bottomMenuContainer : newItemInputContainer
        let viewToGo = bottomMenuVisible ? newItemInputContainer : bottomMenuContainer
        
        bottomMenuVisible = !bottomMenuVisible
        
        UIView.transition(from: currentView!,
                          to: viewToGo!,
                          duration: duration,
                          options: [.transitionCrossDissolve, .showHideTransitionViews],
                          completion: nil)
    }
    
    fileprivate func AddItem(title: String)
    {
        if let manager = listManager
        {
            awaitenNotifations = awaitenNotifations + 1
            manager.AddNewItem(title: title)
        }
    }
    
    @IBAction func DetailItemsButtonPressed(_ sender: Any)
    {
        self.displayDetails = !self.displayDetails
        
        UpdateBottomBar()
        
        tableView.reloadData()
    }
    
    @IBAction func RemoveItemsButtonPressed(_ sender: Any)
    {
        if (self.displayEdit)
        {
            SetDisplayEdit(false)
        }
        else
        {
            ShowEditPopup()
        }
    }
    
    @IBAction func AddItemButtonPressed(_ sender: Any)
    {
        SwitchBottomContainer(duration: 0.2)
        newItemNameTextField.becomeFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "GoToListEditSeque"
        {
            let editVC = segue.destination as! ListEditViewController
            editVC.listManager = listManager
        }
    }
    
    fileprivate func ShowEditPopup()
    {
        let title = "Remove all crossed items?"
        let popup = PopupDialog(title: title, message: nil, buttonAlignment: .vertical)
        
        let buttonAll = DestructiveButton(title: "All")
        {
            if let manager = self.listManager
            {
                self.itemsToRemove = manager.RemoveChecked()
                SVProgressHUD.show(withStatus: "removing...")
            }
        }
        let buttonSelect = DefaultButton(title: "Select")
        {
            self.SetDisplayEdit(true)
        }
        let buttonCancel = CancelButton(title: "Cancel")
        {
            
        }
    
        popup.addButtons([buttonAll, buttonSelect, buttonCancel])
        
        self.present(popup, animated: true, completion: nil)
    }
    
    fileprivate func SetDisplayEdit(_ value: Bool)
    {
        self.displayEdit = value

        self.UpdateBottomBar()

        self.tableView.setEditing(value, animated: true)
        self.tableView.reloadData()
    }
}

//*********************************************************************
// MARK: - Single List Manager Delegate extension
extension SingleListViewController : SingleListManagerDelegate
{
    func AllItemsLoaded()
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
    
    func ItemLoaded()
    {
        tableView.reloadData()
        if (awaitenNotifations > 0)
        {
            self.awaitenNotifations = self.awaitenNotifations - 1
            self.ShowPopupItemSucessfullyAdded()
            self.ScrollToBottom()
        }
    }
    
    func ItemChanged()
    {
       tableView.reloadData()
    }
    
    func NewItemAdded()
    {
        tableView.reloadData()
    }
    
    func ItemRemoved(index: Int)
    {
        if let itemsCount = self.listManager?.itemsCount
        {
            if itemsCount != 0
            {
                let indexPath = IndexPath(row: index, section: 0)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            else
            {
                self.tableView.reloadData()
            }
        }
        
        if (self.itemsToRemove > 0)
        {
            self.itemsToRemove = self.itemsToRemove - 1
            if (self.itemsToRemove == 0)
            {
                SVProgressHUD.showSuccess(withStatus: "Removed.")
                SVProgressHUD.dismiss(withDelay: 0.6)
            }
        }
    }
    
    fileprivate func ShowPopupItemSucessfullyAdded()
    {
        SVProgressHUD.showSuccess(withStatus: "Added.")
        SVProgressHUD.dismiss(withDelay: 0.6)
    }
}

//*********************************************************************
// MARK: - Table View Delegats extension
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
            let detailedText = PrepareDetailedText(item: item)
            
            SetCellStyle(cell: cell!,
                         title: item.title,
                         detailed: detailedText,
                         checked: item.checked)
        }
        else
        {
            SetCellStyle(cell: cell!,
                         title: "Add items!",
                         detailed: "",
                         checked: false)
        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let item = listManager?.GetItem(indexPath.row)
        {
            if item.checked == true
            {
                // TODO: move this to dedicated function or remove
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if self.listManager?.itemsCount != 0
        {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            if let manager = self.listManager
            {
                manager.RemoveItem(index: indexPath.row)
            }
        }
    }
    
    fileprivate func PrepareDetailedText(item: Item) -> String
    {
        if (displayDetails == false)
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
    
    fileprivate func SetCellStyle(cell: UITableViewCell, title: String, detailed: String, checked: Bool)
    {
        if (checked)
        {
            cell.accessoryType = .checkmark
            cell.tintColor = UIColor.systemGray2
            
            let attributedText : NSMutableAttributedString = NSMutableAttributedString(string: title)
            attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedText.length))
            cell.textLabel?.attributedText = attributedText
            cell.textLabel?.textColor = ui_utils.GetCheckedFontColour()
            
            cell.detailTextLabel?.text = detailed
            cell.detailTextLabel?.textColor = ui_utils.GetCheckedFontColour()
        }
        else
        {
            cell.accessoryType = .none
            cell.textLabel?.attributedText = nil
            cell.textLabel?.text = title
            cell.textLabel?.textColor = ui_utils.GetBasicFontColour(self.traitCollection)
            cell.detailTextLabel?.text = detailed
            cell.detailTextLabel?.textColor = ui_utils.GetBasicFontColour(self.traitCollection)
        }
    }
    
    
    fileprivate func ScrollToBottom()
    {
        DispatchQueue.main.async {
            if let man = self.listManager
            {
                let itemsCount = man.itemsCount
                let indexPath = IndexPath(row: itemsCount-1, section: 0)
                
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
}

//*********************************************************************
// MARK: - Text field delegate extension
extension SingleListViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if let newItem = CorrectInput(textField.text)
        {
            self.AddItem(title: newItem)
            textField.text = ""
            return true
        }
        
        self.DismissKeyboard()
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

//*********************************************************************
// MARK: - UIRecognizer gesture Delegate extension
extension SingleListViewController : UIGestureRecognizerDelegate
{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        return self.newItemNameTextField.isFirstResponder
    }
}
