//
//  List.swift
//  SharedList
//
//  Created by Lukasz on 03/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

class List {
    
    enum Keys : String {
        case title = "title"
        case owner_id = "owner_id"
        case items_id = "items_id"
    }
    
    var id : String?
    var title : String = ""
    var owner_id : String = ""
    var items_id : String = ""
    
    func Serializa() -> [String: String] {
        
        return List.Serialize(title: title, owner_id: owner_id, items_id: items_id)
    }
    
    static func Serialize(title : String, owner_id : String, items_id : String) -> [String : String] {
        
        var dict = [String: String]()
        dict[Keys.title.rawValue] = title
        dict[Keys.owner_id.rawValue] = owner_id
        dict[Keys.items_id.rawValue] = items_id
        
        return dict
    }
    
    static func Deserialize(data: [String : String]) -> List {
        
        let newList = List()
        
        newList.title = data[Keys.title.rawValue]!
        newList.owner_id = data[Keys.owner_id.rawValue]!
        newList.items_id = data[Keys.items_id.rawValue]!

        return newList
    }
}
