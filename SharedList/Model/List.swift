//
//  List.swift
//  SharedList
//
//  Created by Lukasz on 03/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase

class List {
    var title : String = ""
    var owner_id : String = ""
    var items_id : String?
    var dbRef : DatabaseReference?
    
    func Serializa() -> [String: String] {
        
        var dict = List.Serialize(title: title, owner_id: owner_id)
        
        if (items_id != nil) {
            dict["items_id"] = items_id
        }
        
        return dict
    }
    
    static func Serialize(title : String, owner_id : String) -> [String : String] {
        
        var dict = [String: String]()
        dict["title"] = title
        dict["owner_id"] = owner_id
        
        return dict
    }
    
    static func Deserialize(data: [String : String]) -> List {
        
        let newList = List()
        
        newList.title = data["title"]!
        newList.owner_id = data["owner_id"]!
        
        if let items_id = data["items_id"] {
            newList.items_id = items_id
        }
        
        return newList
    }
}
