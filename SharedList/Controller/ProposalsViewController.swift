//
//  ProposalsViewController.swift
//  SharedList
//
//  Created by Lukasz on 24/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit
import PopupDialog

class ProposalsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var frbManager : FirebaseManager? = nil {
        
        didSet {
            proposalManager = frbManager?.proposalManager
            proposalManager?.delegates.addDelegate(self)
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
    
    func ProposalRemoved() {
        tableView.reloadData()
    }
}

extension ProposalsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return proposalManager!.proposals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let proposal = proposalManager!.proposals[indexPath.row]
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "proposalCell")
        cell.textLabel!.text = "title: loading..."
        cell.detailTextLabel!.text = "owner: \(proposal.user_email)"
        
        proposalManager?.GetListNameForProposal(proposal, CompletionHandler: { (returnedTitle) in
            if let title = returnedTitle {
                cell.textLabel!.text = "Title: \(title)"
            } else {
                cell.textLabel!.text = "List no longer exist."
                cell.detailTextLabel!.text = "Removing proposal..."
            }
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let proposal = proposalManager!.proposals[indexPath.row]
        
        let title = proposal.user_email
        let message = proposal.message
        
        let popup = PopupDialog(title: title, message: message)
        
        let acceptButton = DefaultButton(title: "Accept") {
            self.proposalManager?.AcceptProposal(proposal)
        }
        let discardButton = DefaultButton(title: "Discard") {
            self.proposalManager?.RemoveProposal(proposal)
        }
        
        popup.addButtons([acceptButton, discardButton])
        popup.buttonAlignment = .horizontal
        
        self.present(popup, animated: true, completion: nil)
    }
}
