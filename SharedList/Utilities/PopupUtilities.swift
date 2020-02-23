//
//  PopupUtilities.swift
//  SharedList
//
//  Created by Lukasz on 23/02/2020.
//  Copyright © 2020 Lukasz. All rights reserved.
//

import Foundation
import PopupDialog

class popup_utils {
    
    static func GetDefaultButton(traitCollection: UITraitCollection, title: String, callback: @escaping () -> Void) -> DefaultButton
    {
        let button = DefaultButton(title: title, action: callback)
        colour_utils.SetDefaultButtonAppearance(button, traitCollection)
        
        return button
    }
    
    static func GetCancelButton(traitCollection: UITraitCollection, title: String, callback: @escaping () -> Void) -> CancelButton
    {
        let button = CancelButton(title: title, action: callback)
        colour_utils.SetCancelButtonAppearance(button, traitCollection)
        
        return button
    }
}
