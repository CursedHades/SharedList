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
    @IBOutlet var proposalsButton: UIButton!
    
    var selectedListIndex : Int?
    
    fileprivate let loadingGuard = TimeoutGuard()
    fileprivate var loadingInProgress = false
    
    fileprivate var listManager : ListManager?
    fileprivate var proposalManager : ProposalManager?
    var frbManager : FirebaseManager? {
        didSet {
            listManager = frbManager?.listManager
            listManager?.delegate = self
            
            proposalManager = frbManager?.proposalManager
            proposalManager?.delegates.addDelegate(self)
            proposalManager?.LoadData()
            proposalManager?.ActivateObservers()
        }
    }
    
    //*********************************************************************
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "listCell")
        
        InitiateDataLoad()
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
    
    @IBAction func ProposalsPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToProposals", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "goToSingleList")
        {
            guard let listIndex = selectedListIndex else { fatalError("No list was selected") }
            
            selectedListIndex = nil
            
            let singleListVC = segue.destination as! SingleListViewController
            singleListVC.list = listManager!.GetList(listIndex)
            singleListVC.frbManager = frbManager
        }
        
        if (segue.identifier == "goToProposals")
        {
            let proposalVC = segue.destination as! ProposalsViewController
            proposalVC.frbManager = frbManager
        }
    }
    
    fileprivate func InitiateDataLoad() {
        
        loadingInProgress = true
        UpdateUI()
        SVProgressHUD.show(withStatus: "Loading data...")
        
        listManager?.LoadData()
        
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
        proposalsButton.isEnabled = false
    }
    
    fileprivate func EnableUI() {
        listTitleTextField.isEnabled = true
        tableView.allowsSelection = true
        tableView.isScrollEnabled = true
        addListButton.isEnabled = true
        UpdateProposalEnable()
    }
    
    fileprivate func UpdateProposalEnable() {
        if (!loadingInProgress && proposalManager?.proposals.count != 0) {
            proposalsButton.isEnabled = true
        }
        else {
            proposalsButton.isEnabled = false
        }
    }
}

//*********************************************************************
// MARK: - Table View extension
extension ListsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if listManager!.listCount != 0 {
            return listManager!.listCount
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        
        if listManager!.listCount != 0 {
            cell.textLabel?.text = listManager!.GetList(indexPath.row)!.title
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
extension ListsViewController : ListManagerDelegate {
    
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
        listManager?.ActivateObservers()
        
        loadingGuard.Deactivate()
        DismisDataLoad(success: true)
    }
}

//*********************************************************************
// MARK: - Proposal Manager extension
extension ListsViewController : ProposalManagerDelegate {
    
    func ProposalAdded() {
        UpdateProposalEnable()
    }
    
    func ProposalRemoved() {
        UpdateProposalEnable()
    }
}

//*********************************************************************
// MARK: - Timeout Guard extension
extension ListsViewController : TimeoutGuardDelegate {
    
    func TimeoutGuardFired() {
        DismisDataLoad(success: false)
    }
}
