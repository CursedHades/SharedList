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
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var messageTextView: UITextView!
    @IBOutlet var listImageView: UIImageView!
    
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
        let popup = PopupDialog(viewController: vc)
        
        let listTitle = invitation.list?.title
        let sender = invitation.list?.users?[invitation.sender_user_id]
        let message = invitation.message
        
        let title = "\(sender!) invited you!"
        
        let boldFont = UIFont(name: "HelveticaNeue-Bold", size: 17.0)!
        
        let attributedText : NSMutableAttributedString = NSMutableAttributedString(string: title)
        attributedText.addAttribute(NSAttributedString.Key.font, value: boldFont, range: NSMakeRange(0, sender!.count))
        
        vc.messageTextView.text = message
        vc.titleLabel.attributedText = attributedText
        vc.subtitleLabel.text = listTitle
        
        vc.listImageView.image = ui_utils.GetListImage(vc.traitCollection)
        
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
