//
//  ColourUtilities.swift
//  SharedList
//
//  Created by Lukasz on 20/02/2020.
//  Copyright © 2020 Lukasz. All rights reserved.
//

import Foundation
import UIKit

class ui_utils {
    
    enum BottomBarIcons : String
    {
        case Add = "plus.square"
        case Remove = "minus.square"
        case Details = "questionmark.square"
        case Share = "square.and.arrow.up"
    }
    
    static func GetBottomBarColour() ->UIColor
    {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray6
        } else {
            return UIColor.systemGray
        }
    }
    
    static func GetCheckedFontColour() -> UIColor
    {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray3
        } else {
            return UIColor.systemGray
        }
    }
    
    static func GetBasicFontColour(_ traitCollection: UITraitCollection) -> UIColor
    {
        if #available(iOS 13.0, *)
        {
            return UIColor.label
        }
        else
        {
            if (traitCollection.userInterfaceStyle == .dark)
            {
                return UIColor.white
            }
            else
            {
                return UIColor.black
            }
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
    
    static func SetSfSymbolButton(button: UIButton,
                                  icon: BottomBarIcons,
                                  selected : Bool,
                                  traitCollection: UITraitCollection)
    {
        let symbolName = icon.rawValue + (selected ? ".fill" : "")
        let image = UIImage(systemName: symbolName)
        button.setImage(image, for: .normal)
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: UIFont.systemFontSize * 2, weight: .medium, scale: .large)
        button.imageView?.preferredSymbolConfiguration = symbolConfig

        if traitCollection.userInterfaceStyle == .light
        {
            button.imageView?.tintColor = .black
        }
        else
        {
            button.imageView?.tintColor = .white
        }
    }
}
