//
//  Item.swift
//  SharedList
//
//  Created by Lukasz on 04/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase

class Item {
    var title : String = ""
    var dbRef : DatabaseReference?
    
    static func Serialize(title: String) -> [String : String] {
    
        var dict = [String : String]()
        dict["title"] = title
        
        return dict
    }
    
    static func Deserialize(data: [String : String]) -> Item {
        
        let newItem = Item()
        newItem.title = data["title"]!
        
        return newItem
    }
}
