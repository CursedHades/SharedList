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
    var willDismissCallback : ((String?, String?) -> Void)?
    @IBOutlet var messageTextView: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        emailTextField.keyboardType = .emailAddress
        emailTextField.returnKeyType = .done
        
        messageTextView.delegate = self
        messageTextView.keyboardType = .default
        messageTextView.returnKeyType = .done
        
        emailTextField.becomeFirstResponder()
        
        messageTextView.clipsToBounds = true
        messageTextView.layer.cornerRadius = 5.0
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
    }
    
    fileprivate func DismissWithCallback(email: String?, message: String?)
    {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        
        if let callback = willDismissCallback
        {
            callback(email, message)
        }
    }
    
    static func PreparePopup(WillDismissCallback: @escaping (String?, String?) -> Void) -> PopupDialog
    {
        let vc = ShareListViewController()
        vc.willDismissCallback = WillDismissCallback
        let popup = PopupDialog(viewController: vc)
        let sendButton = DefaultButton(title: "Send invitation")
        {
            vc.DismissWithCallback(email: vc.emailTextField.text,
                                   message: vc.messageTextView.text)
        }
        let cancelButton = CancelButton(title: "Cancel")
        {
        }
        
        popup.addButtons([sendButton, cancelButton])
        
        return popup
    }
}

//*********************************************************************
// MARK: extension UITextFieldDelegate
extension ShareListViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
//        DismissWithCallback(email: textField.text)
        self.messageTextView.becomeFirstResponder()
        return true
    }
}

//*********************************************************************
// MARK: - extension UITextViewDelegate
extension ShareListViewController : UITextViewDelegate
{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if text == "\n"
        {
            self.messageTextView.resignFirstResponder()
            return false
        }
        
        return true
    }
}
