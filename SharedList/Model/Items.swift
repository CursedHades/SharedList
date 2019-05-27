//
//  Items.swift
//  SharedList
//
//  Created by Lukasz on 23/05/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

class Items
{
    enum Keys : String {
        case list_id = "list_id"
        case items = "items"
    }
    
    let id : String
    fileprivate(set) var list_id : String
    
    fileprivate init(id: String, listId: String) {
        self.id = id
        self.list_id = listId
    }
    
    static func Deserialize(id: String, data: [String : Any]) -> Items
    {
        return Items(id: id,
                     listId: data[Keys.list_id.rawValue] as! String)
    }
}
