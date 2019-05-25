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

    @IBOutlet var listTitleTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var addListButton: UIButton!
    @IBOutlet var invitationsButton: UIButton!
    
    var selectedListIndex : Int?
    
    fileprivate let loadingGuard = TimeoutGuard()
    fileprivate var loadingInProgress = false
    
    fileprivate var listsManager : ListsManager?
    fileprivate var invitationManager : InvitationManager?
    var frbManager : FirebaseManager? {
        didSet {
            listsManager = frbManager?.listsManager
            listsManager?.delegate = self
            
            invitationManager = frbManager?.invitationManager
            invitationManager?.delegates.addDelegate(self)
            invitationManager?.LoadData()
            invitationManager?.ActivateObservers()
        }
    }
    
    //*********************************************************************
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        InitiateDataLoad()
    }

    @IBAction func AddListPressed(_ sender: Any) {
        
        if (listTitleTextField.text?.count == 0) {
            print("cannot add list with empty name")
        }
        else {
            let listTitle = listTitleTextField.text!
            listsManager!.AddNewList(title: listTitle)
        }
    }
    
    @IBAction func InvitationsPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToInvitations", sender: self)
    }
    
    @IBAction func LogOutPressed(_ sender: UIBarButtonItem) {
        frbManager?.authManager.LogOut()
    
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "goToSingleList")
        {
            guard let listIndex = selectedListIndex else { fatalError("No list was selected") }
            
            selectedListIndex = nil
            
            let singleListVC = segue.destination as! SingleListViewController
            singleListVC.listManager = frbManager?.PrepareSingleListManager(list: listsManager!.GetList(listIndex)!)
//            singleListVC.list = listsManager!.GetList(listIndex)
//            singleListVC.frbManager = frbManager
        }
        
        if (segue.identifier == "goToInvitations")
        {
            let invitationVC = segue.destination as! InvitationsViewController
            invitationVC.frbManager = frbManager
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
        listTitleTextField.isEnabled = false
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        addListButton.isEnabled = false
        invitationsButton.isEnabled = false
    }
    
    fileprivate func EnableUI() {
        listTitleTextField.isEnabled = true
        tableView.allowsSelection = true
        tableView.isScrollEnabled = true
        addListButton.isEnabled = true
        UpdateInvitationEnable()
    }
    
    fileprivate func UpdateInvitationEnable() {
        if (!loadingInProgress && invitationManager?.invitations.count != 0) {
            invitationsButton.isEnabled = true
        }
        else {
            invitationsButton.isEnabled = false
        }
    }
}

//*********************************************************************
// MARK: - Table View extension
extension ListsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if listsManager!.listCount != 0 {
            return listsManager!.listCount
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        
        if listsManager!.listCount != 0 {
            cell.textLabel?.text = listsManager!.GetList(indexPath.row)!.title
        }
        else {
            cell.textLabel?.text = "Add new list"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        listManager?.RemoveList(index: indexPath.row)
        
        selectedListIndex = indexPath.row
        performSegue(withIdentifier: "goToSingleList", sender: self)
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
        
        tableView.reloadData()
        listsManager?.ActivateObservers()
        
        loadingGuard.Deactivate()
        DismisDataLoad(success: true)
    }
}

//*********************************************************************
// MARK: - Invitation Manager extension
extension ListsViewController : InvitationManagerDelegate {
    
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
