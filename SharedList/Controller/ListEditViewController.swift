//
//  ListEditViewController.swift
//  SharedList
//
//  Created by Lukasz on 17/06/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit
import PopupDialog

class ListEditViewController: UIViewController {
    
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var bottomBarContainer: UIView!
    
    var listManager : SingleListManager?
    let shareManager = ShareListManager()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        shareManager.delegate = self
        
        title = listManager?.list.title
        
        bottomBarContainer.backgroundColor = ui_utils.GetBottomBarColour()
        ui_utils.SetSfSymbolButton(button: shareButton,
                                   icon: .Share,
                                   selected: false,
                                   traitCollection: self.traitCollection)
    }
    
    @IBAction func ShareButtonPressed(_ sender: Any)
    {
        let popup = ShareListViewController.PreparePopup { (email, message) in
            self.TryToSend(email: email, message: message)
        }
        self.present(popup, animated: true)
    }
    
    fileprivate func TryToSend(email: String?, message: String?)
    {
        if (email == nil || email! == "")
        {
            self.ShowInvalidEmailPopup()
            return
        }
        
        shareManager.Share(destUserEmail: email!,
                           message: message!,
                           listId: listManager!.list.id)
    }
    
    fileprivate func ShowPopupWithMessage(_ message: String, cancelButton: String)
    {
        let popup = PopupDialog(title: message, message: nil)
        let cancelButton = CancelButton(title: cancelButton)
        {}
        
        popup.addButton(cancelButton)
        
        self.present(popup, animated: true)
    }
    
    fileprivate func ShowInvalidEmailPopup()
    {
        ShowPopupWithMessage("Invalid email address.",
                             cancelButton: "Cancel")
    }
}

extension ListEditViewController : ShareListManagerDelegate
{
    func InvitationSent()
    {
        ShowPopupWithMessage("Invitation sent.", cancelButton: "OK")
    }
}
