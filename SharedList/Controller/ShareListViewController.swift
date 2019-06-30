//
//  ShareListViewController.swift
//  SharedList
//
//  Created by Lukasz on 17/06/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit
import PopupDialog

class ShareListViewController: UIViewController
{
    @IBOutlet var emailTextField: UITextField!
    var willDismissCallback : ((String?) -> Void)?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        emailTextField.keyboardType = .default
        emailTextField.returnKeyType = .send
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    fileprivate func DismissWithCallback(email: String?)
    {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        
        if let callback = willDismissCallback
        {
            callback(email)
        }
    }
    
    static func PreparePopup(WillDismissCallback: @escaping (String?) -> Void) -> PopupDialog
    {
        let vc = ShareListViewController()
        vc.willDismissCallback = WillDismissCallback
        let popup = PopupDialog(viewController: vc)
        let sendButton = DefaultButton(title: "Send invitation")
        {
            vc.DismissWithCallback(email: vc.emailTextField.text)
        }
        let cancelButton = CancelButton(title: "Cancel")
        {
            vc.DismissWithCallback(email: "")
        }
        
        popup.addButtons([sendButton, cancelButton])
        
        return popup
    }
}

extension ShareListViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        DismissWithCallback(email: textField.text)
        return true
    }
}
