//
//  ColourUtilities.swift
//  SharedList
//
//  Created by Lukasz on 20/02/2020.
//  Copyright © 2020 Lukasz. All rights reserved.
//

import Foundation
import UIKit
import PopupDialog

class colour_utils {
    
    static func GetBottomBarColour() ->UIColor
    {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray5
        } else {
            return UIColor.systemGray
        }
    }
    
    static func GetListImage(_ traitCollection: UITraitCollection) -> UIImage?
    {
        if (traitCollection.userInterfaceStyle == .dark)
        {
            return UIImage(named: "list_dark.png")
        }
        else
        {
            return UIImage(named: "list_light.png")
        }
    }
    
    static func GetAddListImage(_ traitCollection: UITraitCollection) -> UIImage?
    {
        if (traitCollection.userInterfaceStyle == .dark)
        {
            return UIImage(named: "add_dark.png")
        }
        else
        {
            return UIImage(named: "add_light.png")
        }
    }
    
    static func SetDefaultButtonAppearance(_ button: DefaultButton, _ traitCollection: UITraitCollection)
    {
        button.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        button.titleColor     = .white
        button.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        button.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
    }
    
    static func SetCancelButtonAppearance(_ button: CancelButton, _ traitCollection: UITraitCollection)
    {
        button.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        button.titleColor     = UIColor(white: 0.6, alpha: 1)
        button.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        button.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
    }
}
