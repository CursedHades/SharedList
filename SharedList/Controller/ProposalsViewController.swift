//
//  ProposalsViewController.swift
//  SharedList
//
//  Created by Lukasz on 24/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit

class ProposalsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var frbManager : FirebaseManager? = nil {
        
        didSet {
            proposalManager = frbManager?.proposalManager
        }
    }
    
    fileprivate var proposalManager : ProposalManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
         tableView.register(UITableViewCell.self, forCellReuseIdentifier: "proposalCell")
    }
}

extension ProposalsViewController : ProposalManagerDelegate {
    func ProposalAdded() {
        tableView.reloadData()
    }
}

extension ProposalsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return proposalManager!.proposals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        cell.textLabel!.text = proposalManager!.proposals[indexPath.row].user_email
        
        return cell
    }
}
