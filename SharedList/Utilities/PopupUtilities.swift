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
    
    static func SetupPopupAppearance(traitCollection: UITraitCollection)
    {
        if (traitCollection.userInterfaceStyle != .dark)
        {
            return
        }
        
        let pv = PopupDialogDefaultView.appearance()
        pv.titleFont    = UIFont(name: "HelveticaNeue-Light", size: 16)!
        pv.titleColor   = .white
        pv.messageFont  = UIFont(name: "HelveticaNeue", size: 14)!
        pv.messageColor = UIColor(white: 0.8, alpha: 1)

        let pcv = PopupDialogContainerView.appearance()
        pcv.backgroundColor = UIColor(red:0.21, green:0.21, blue:0.25, alpha:1.00)
        pcv.cornerRadius    = 2
        pcv.shadowEnabled   = true
        pcv.shadowColor     = .black
        pcv.shadowOpacity   = 0.6
        pcv.shadowRadius    = 20
        pcv.shadowOffset    = CGSize(width: 0, height: 8)

        let ov = PopupDialogOverlayView.appearance()
        ov.blurEnabled     = true
        ov.blurRadius      = 30
        ov.liveBlurEnabled = true
        ov.opacity         = 0.6
        ov.color           = .black

        let defaultButton = DefaultButton.appearance()
        defaultButton.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        defaultButton.titleColor     = .white
        defaultButton.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        defaultButton.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)

        let cancelButton = CancelButton.appearance()
        cancelButton.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        cancelButton.titleColor     = UIColor(white: 0.6, alpha: 1)
        cancelButton.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        cancelButton.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
        
        let destButton = DestructiveButton.appearance()
        destButton.titleFont        = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        
        destButton.buttonColor      = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        destButton.separatorColor   = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
    }
}
