//
//  Item.swift
//  SharedList
//
//  Created by Lukasz on 04/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

class Item {
    
    enum Keys : String {
        case title = "title"
    }
    
    var id : String?
    var title : String = ""
    
    static func Serialize(title: String) -> [String : String] {
    
        var dict = [String : String]()
        dict[Keys.title.rawValue] = title
        
        return dict
    }
    
    static func Deserialize(data: [String : String]) -> Item {
        
        let newItem = Item()
        newItem.title = data[Keys.title.rawValue]!
        
        return newItem
    }
}
