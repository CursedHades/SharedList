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
        case checked = "checked"
        case author_id = "author_id"
        case checked_by_id = "checked_by_id"
    }
    
    let itemsId : String
    let id : String
    let authorId : String
    let checkedById : String
    private(set) var title : String
    private(set) var checked : Bool
    private(set) var authorName : String = ""
    private(set) var checkedByName : String = ""
    
    private let frbPrefix : String
    
    func Update(data : [String : Any?])
    {
        for key in data.keys
        {
            if key == Keys.title.rawValue
            {
                if let newTitle = data[key] as? String
                {
                    title = newTitle
                }
            }
            else if key == Keys.checked.rawValue
            {
                if let newDone = data[key] as? Bool
                {
                    checked = newDone
                }
            }
        }
    }
    
    func PathForKey(_ key: Keys) -> String
    {
        return Item.Path(frbPrefix, key)
    }
    
    func UpdateAuthorName(_ newName : String)
    {
        self.authorName = newName
    }
    
    func UpdateCheckedByName(_ newName : String)
    {
        self.checkedByName = newName
    }
    
    fileprivate init(itemsId: String,
                     id:String,
                     title: String,
                     checked: Bool,
                     authorId: String,
                     checkedById: String = "NONE")
    {
        self.itemsId = itemsId
        self.id = id
        self.title = title
        self.checked = checked
        self.authorId = authorId
        self.checkedById = checkedById
        
        self.frbPrefix = frb_utils.ItemPath(itemsId, id)
    }
    
    static func Path(_ prefix: String, _ key: Keys) -> String
    {
        return prefix + "/\(key.rawValue)"
    }
    
    static func Serialize(itemsId: String,
                          id:String,
                          title: String,
                          checked: Bool,
                          authorId: String,
                          doneById: String = "NONE") -> [String : Any]
    {
        let prefix = frb_utils.ItemPath(itemsId, id)
        
        var dict = [String : Any]()
        
        dict[Path(prefix, Keys.title)] = title
        dict[Path(prefix, Keys.checked)] = checked
        dict[Path(prefix, Keys.author_id)] = authorId
        dict[Path(prefix, Keys.checked_by_id)] = doneById
        
        return dict
    }
    
    static func Deserialize(itemsId: String,
                            id: String,
                            data: [String : Any]) -> Item
    {
        return Item(itemsId: itemsId,
                    id: id,
                    title: data[Keys.title.rawValue] as! String,
                    checked: data[Keys.checked.rawValue] as! Bool,
                    authorId: data[Keys.author_id.rawValue] as! String)
    }
}
