//
//  ListsViewController.swift
//  SharedList
//
//  Created by Lukasz on 03/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit
import SVProgressHUD

class ListsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var bottomBarVIew: UIView!
    
    @IBOutlet var addListButton: UIButton!
    @IBOutlet var invitationsButton: UIButton!
    
    var selectedListIndex : Int?
    
    fileprivate let loadingGuard = TimeoutGuard()
    fileprivate var loadingInProgress = false
    
    var frbManager : FirebaseManager?
    {
        didSet
        {
            listsManager = frbManager?.PrepareListsManager()
            listsManager?.delegate = self
            
            invitationManager = frbManager?.PrepareInvitationManager(listsManager: listsManager!)
            invitationManager?.delegates.addDelegate(self)
        }
    }
  
    fileprivate var listsManager : ListsManager?
    fileprivate var invitationManager : InvitationManager?
    
    //*********************************************************************
    // MARK: - Functions
    override func viewDidLoad()
    {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        InitiateDataLoad()
    }

    @IBAction func AddListPressed(_ sender: Any) {
        
        let popup = AddListViewController.PreparePopup(traitCollection: self.traitCollection) { (listTitle) in
            self.listsManager!.AddNewList(title: listTitle!)
        }
        self.present(popup, animated: true)
    }
    
    @IBAction func InvitationsPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToInvitations", sender: self)
    }
    
    @IBAction func LogOutPressed(_ sender: UIBarButtonItem) {
        frbManager?.authManager.LogOut()
    
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "goToSingleList")
        {
            guard let listIndex = selectedListIndex else { fatalError("No list was selected") }
            
            selectedListIndex = nil
            
            let singleListVC = segue.destination as! SingleListViewController
            singleListVC.listManager = frbManager?.PrepareSingleListManager(list: listsManager!.GetList(listIndex)!)
        }
        
        if (segue.identifier == "goToInvitations")
        {
            let invitationVC = segue.destination as! InvitationsViewController
            invitationVC.invManager = invitationManager
        }
    }
    
    fileprivate func InitiateDataLoad() {
        
        loadingInProgress = true
        UpdateUI()
        SVProgressHUD.show(withStatus: "Loading data...")
        
        listsManager?.LoadData()
        
        loadingGuard.delegate = self
        loadingGuard.Activate()
    }
    
    //*********************************************************************
    // MARK: - UI management
    fileprivate func UpdateUI() {
        
        ui_utils.SetSfSymbolButton(button: addListButton,
                                   icon: .Add,
                                   selected: false,
                                   traitCollection: self.traitCollection)
        
        bottomBarVIew.backgroundColor = ui_utils.GetBottomBarColour()
        
        if loadingInProgress {
            DisableUI()
        }
        else {
            EnableUI()
        }
    }
    
    fileprivate func DismisDataLoad(success: Bool) {
        
        if (SVProgressHUD.isVisible()) {
            if (success) {
                SVProgressHUD.showSuccess(withStatus: "Awsome!")
            }
            else {
                SVProgressHUD.showError(withStatus: "Failed.")
            }
            
            SVProgressHUD.dismiss(withDelay: 0.6) {
                self.loadingInProgress = false
                self.UpdateUI()
            }
        }
    }
    
    fileprivate func DisableUI() {
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        addListButton.isEnabled = false
        invitationsButton.isEnabled = false
    }
    
    fileprivate func EnableUI() {
        tableView.allowsSelection = true
        tableView.isScrollEnabled = true
        addListButton.isEnabled = true
        UpdateInvitationEnable()
    }
    
    fileprivate func UpdateInvitationEnable()
    {
        if let invManager = invitationManager
        {
            let enable = (!loadingInProgress && invManager.HasInvitation())
            invitationsButton.isEnabled = enable
        }
        else
        {
            invitationsButton.isEnabled = false
        }
    }
}

//*********************************************************************
// MARK: - Table View extension
extension ListsViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let itemsCount = listsManager?.listCount
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        
        cell.backgroundColor = .systemGray6
        
        if let list = listsManager?.GetList(indexPath.row)
        {
            cell.textLabel?.text = list.title
        }
        else
        {
            cell.textLabel?.text = "Add new list"
        }
        
        cell.imageView?.image = ui_utils.GetListImage(self.traitCollection)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
//        listManager?.RemoveList(index: indexPath.row)
        
        selectedListIndex = indexPath.row
        performSegue(withIdentifier: "goToSingleList", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
}

//*********************************************************************
// MARK: - List Manager extension
extension ListsViewController : ListsManagerDelegate {
    
    func ListUpdated() {
        tableView.reloadData()
    }
    
    func NewListAdded() {
        
        tableView.reloadData()
        
        if (loadingGuard.isActive) {
            loadingGuard.Refresh()
        }
    }
    
    func ListRemoved() {
        
        tableView.reloadData()
    }
    
    func DataLoaded() {
        
        if let manager = listsManager
        {
            manager.SortListsByCreationDate()
        }
        
        tableView.reloadData()
        
        loadingGuard.Deactivate()
        DismisDataLoad(success: true)
    }
}

//*********************************************************************
// MARK: - Invitation Manager extension
extension ListsViewController : InvitationManagerDelegate
{
    func UserAddedToList() {
        
    }
    
    func InvitationAdded() {
        UpdateInvitationEnable()
    }
    
    func InvitationRemoved() {
        UpdateInvitationEnable()
    }
}

//*********************************************************************
// MARK: - Timeout Guard extension
extension ListsViewController : TimeoutGuardDelegate {
    
    func TimeoutGuardFired() {
        DismisDataLoad(success: false)
    }
}
