//
//  AddListViewController.swift
//  SharedList
//
//  Created by Lukasz on 19/02/2020.
//  Copyright © 2020 Lukasz. All rights reserved.
//

import UIKit
import PopupDialog

class AddListViewController: UIViewController {
    
    @IBOutlet var listTitleTextField: UITextField!
    @IBOutlet var listImageView: UIImageView!
    
    var willDismissCallback : ((String?) -> Void)?
        
        override func viewDidLoad()
        {
            super.viewDidLoad()
            
            listImageView.image = colour_utils.GetListImage(self.traitCollection)
            
            listTitleTextField.delegate = self
            listTitleTextField.keyboardType = .emailAddress
            listTitleTextField.returnKeyType = .send
            
            listTitleTextField.becomeFirstResponder()
        }
        
        override func viewDidAppear(_ animated: Bool)
        {
            super.viewDidAppear(animated)
            
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
        
    static func PreparePopup(traitCollection: UITraitCollection, WillDismissCallback: @escaping (String?) -> Void) -> PopupDialog
        {
            let vc = AddListViewController()
            vc.willDismissCallback = WillDismissCallback
            let popup = PopupDialog(viewController: vc)
            let sendButton = popup_utils.GetDefaultButton(traitCollection: traitCollection, title: "Add")
            {
                vc.DismissWithCallback(email: vc.listTitleTextField.text)
            }
            let cancelButton = popup_utils.GetCancelButton(traitCollection: traitCollection, title: "Cancel")
            {
            }
            
            popup.addButtons([sendButton, cancelButton])
            
            return popup
        }
    }

    extension AddListViewController : UITextFieldDelegate
    {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool
        {
            DismissWithCallback(email: textField.text)
            return true
        }
    }
