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
    
    let id : String
    private(set) var title : String
    let owner_id : String
    let items_id : String
    
    fileprivate init(id: String, title: String, ownerId: String, itemsId: String) {
        self.id = id
        self.title = title
        self.owner_id = ownerId
        self.items_id = itemsId
    }
    
    func Update(data : [String : Any?]) {
        
        let keys = data.keys
        for key in keys {
            if key == Keys.title.rawValue {
                if let newTitle = data[key] as? String {
                    title = newTitle
                }
            }
        }
    }
    
    func Serializa() -> [String: Any] {
        
        return List.Serialize(title: title, owner_id: owner_id, items_id: items_id)
    }
    
    static func Serialize(title : String, owner_id : String, items_id : String) -> [String : Any] {
        
        var dict = [String: Any]()
        dict[Keys.title.rawValue] = title
        dict[Keys.owner_id.rawValue] = owner_id
        dict[Keys.items_id.rawValue] = items_id
        
        return dict
    }
    
    static func Deserialize(id: String, data: [String : Any]) -> List {
        
        return List(id: id,
                    title: data[Keys.title.rawValue] as! String,
                    ownerId: data[Keys.owner_id.rawValue] as! String,
                    itemsId: data[Keys.items_id.rawValue] as! String)
    }
}
