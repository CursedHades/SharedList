//
//  InvitationViewController.swift
//  SharedList
//
//  Created by Lukasz on 10/03/2020.
//  Copyright © 2020 Lukasz. All rights reserved.
//

import UIKit
import PopupDialog

class InvitationViewController: UIViewController {
    
    enum Response {
        case Accepted
        case Posponed
        case Discarded
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    static func PreparePopup(invitation: Invitation,
                             traitCollection: UITraitCollection,
                             WillDismissCallback: @escaping (Response) -> Void) -> PopupDialog
    {
        let vc = InvitationViewController()
//        vc.willDismissCallback = WillDismissCallback
        let popup = PopupDialog(viewController: vc)
        
        let title = invitation.list?.title
        let message = invitation.list?.users?[invitation.sender_user_id]
        
        let acceptButton = DefaultButton(title: "Accept")
        {
            WillDismissCallback(.Accepted)
        }
        let cancelButton = CancelButton(title: "Later")
        {
            WillDismissCallback(.Posponed)
        }
        let discardButton = DestructiveButton(title: "Discard")
        {
            WillDismissCallback(.Discarded)
        }
        
        popup.addButtons([acceptButton, cancelButton, discardButton])
        popup.buttonAlignment = .vertical
        
        return popup
    }

}
