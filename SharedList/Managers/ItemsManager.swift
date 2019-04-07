//
//  ItemsManager.swift
//  SharedList
//
//  Created by Lukasz on 07/04/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation

protocol ItemsManagerDelegate : class {
    
}

class ItemsManager {
    
    weak var delegate : ItemsManagerDelegate?
}
