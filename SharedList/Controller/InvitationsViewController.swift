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
    
    var invManager : InvitationManager? = nil {
        didSet {
            invManager?.delegates.addDelegate(self)
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension InvitationsViewController : InvitationManagerDelegate
{
    func UserAddedToList()
    {
        tableView.reloadData()
    }
    
    func InvitationAdded()
    {
        tableView.reloadData()
    }
    
    func InvitationRemoved()
    {
        tableView.reloadData()
    }
}

extension InvitationsViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return invManager!.invitations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let invitation = invManager!.invitations[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvitationCell")
        cell?.textLabel?.text = "loading..."
        cell?.detailTextLabel?.text = "loading..."
        
        invManager?.GetListForInvitation(index: indexPath.row)
        { (invitedList) in
            if let list = invitedList
            {
                cell?.textLabel?.text = "List: \(list.title)"
                if let userName = list.users?[invitation.sender_user_id]
                {
                    cell?.detailTextLabel?.text = "\(userName) invited you."
                }
                else
                {
                    cell?.detailTextLabel?.text = ""
                }
            }
            else
            {
                cell?.textLabel?.text = "List no longer exist."
                cell?.detailTextLabel?.text = "Removing invitation..."
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let popup = PrepareInvitationPopup(index: indexPath.row)
        self.present(popup, animated: true, completion: nil)
    }
    
    fileprivate func PrepareInvitationPopup(index: Int) -> PopupDialog
    {
        let invitation = invManager!.invitations[index]
        
        let title = invitation.list?.title
        let message = invitation.list?.users?[invitation.sender_user_id]
        
        let popup = PopupDialog(title: title, message: message)
        
        let acceptButton = DefaultButton(title: "Accept")
        {
            self.invManager?.AcceptInvitation(at: index)
        }
        let cancelButton = CancelButton(title: "Cancel")
        {
            
        }
        let discardButton = DestructiveButton(title: "Discard")
        {
            self.invManager?.RemoveInvitation(at: index)
        }
        
        popup.addButtons([acceptButton, cancelButton, discardButton])
        popup.buttonAlignment = .vertical
        
        return popup
    }
}
