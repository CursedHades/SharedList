//
//  ViewControllersCommon.swift
//  SharedList
//
//  Created by Lukasz on 17/07/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import UIKit

class vc_utils
{
    static func SetupKeyboard(textField: UITextField)
    {
        textField.keyboardType = .default
        textField.returnKeyType = .done
    }
}
