//
//  ColourUtilities.swift
//  SharedList
//
//  Created by Lukasz on 20/02/2020.
//  Copyright © 2020 Lukasz. All rights reserved.
//

import Foundation
import UIKit

class colour_utils {
    
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
}
