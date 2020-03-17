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
        
        invManager?.GetListForInvitation(index: indexPath.row)
        { (invitedList) in
            if let list = invitedList
            {
                if let userName = list.users?[invitation.sender_user_id]
                {
                    cell?.textLabel?.text = "Invitation from: \(userName)"
                }
            }
            else
            {
                cell?.textLabel?.text = "List no longer exist."
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let index = indexPath.row
        let invitation = invManager!.invitations[index]
        let popup = InvitationViewController.PreparePopup(invitation: invitation,
                                                          traitCollection: self.traitCollection)
        { (response) in
            switch response
            {
            case .Accepted:
                self.invManager?.AcceptInvitation(at: index)
                
            case .Discarded:
                self.invManager?.RemoveInvitation(at: index)
            
            default:
                return
            }
        }
        
        self.present(popup, animated: true, completion: nil)
    }
}
