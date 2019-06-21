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
    
    var listManager : SingleListManager?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = listManager?.list.title
    }
    
    @IBAction func ShareButtonPressed(_ sender: Any)
    {
        let popup = ShareListViewController.PreparePopup { (email) in
            print("email to send :\(email)")
        }
        self.present(popup, animated: true)
    }
}
