//
//  InvitationsViewController.swift
//  SharedList
//
//  Created by Lukasz on 24/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit
import PopupDialog

class InvitationsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var frbManager : FirebaseManager? = nil {
        
        didSet {
//            invitationManager = frbManager?.invitationManager
            invitationManager?.delegates.addDelegate(self)
        }
    }
    
    fileprivate var invitationManager : InvitationManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "invitationCell")
        
        
    }
}

extension InvitationsViewController : InvitationManagerDelegate {
    
    func InvitationAdded() {
        tableView.reloadData()
    }
    
    func InvitationRemoved() {
        tableView.reloadData()
    }
}

extension InvitationsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return invitationManager!.invitations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let invitation = invitationManager!.invitations[indexPath.row]
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "invitationCell")
        cell.textLabel!.text = "title: loading..."
        cell.detailTextLabel!.text = "owner: \(invitation.user_email)"
        
        invitationManager?.GetListNameForInvitation(invitation, CompletionHandler: { (returnedTitle) in
            if let title = returnedTitle {
                cell.textLabel!.text = "Title: \(title)"
            } else {
                cell.textLabel!.text = "List no longer exist."
                cell.detailTextLabel!.text = "Removing invitation..."
            }
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let invitation = invitationManager!.invitations[indexPath.row]
        
        let title = invitation.user_email
        let message = invitation.message
        
        let popup = PopupDialog(title: title, message: message)
        
        let acceptButton = DefaultButton(title: "Accept") {
            self.invitationManager?.AcceptInvitation(invitation)
        }
        let discardButton = DefaultButton(title: "Discard") {
            self.invitationManager?.RemoveInvitation(invitation)
        }
        
        popup.addButtons([acceptButton, discardButton])
        popup.buttonAlignment = .horizontal
        
        self.present(popup, animated: true, completion: nil)
    }
}
