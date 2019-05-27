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
        case done = "done"
        case author_id = "author_id"
        case done_by_id = "done_by_id"
    }
    
    let itemsId : String
    let id : String
    let authorId : String
    let doneById : String
    private(set) var title : String
    private(set) var done : Bool
    private(set) var authorName : String = ""
    private(set) var doneByName : String = ""
    
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
            else if key == Keys.done.rawValue
            {
                if let newDone = data[key] as? Bool
                {
                    done = newDone
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
    
    func UpdateDoneByName(_ newName : String)
    {
        self.doneByName = newName
    }
    
    fileprivate init(itemsId: String,
                     id:String,
                     title: String,
                     done: Bool,
                     authorId: String,
                     doneById: String = "NONE")
    {
        self.itemsId = itemsId
        self.id = id
        self.title = title
        self.done = done
        self.authorId = authorId
        self.doneById = doneById
        
        self.frbPrefix = frb_utils.ItemPath(itemsId, id)
    }
    
    static func Path(_ prefix: String, _ key: Keys) -> String
    {
        return prefix + "/\(key.rawValue)"
    }
    
    static func Serialize(itemsId: String,
                          id:String,
                          title: String,
                          done: Bool,
                          authorId: String,
                          doneById: String = "NONE") -> [String : Any]
    {
        let prefix = frb_utils.ItemPath(itemsId, id)
        
        var dict = [String : Any]()
        
        dict[Path(prefix, Keys.title)] = title
        dict[Path(prefix, Keys.done)] = done
        dict[Path(prefix, Keys.author_id)] = authorId
        dict[Path(prefix, Keys.done_by_id)] = doneById
        
        return dict
    }
    
    static func Deserialize(itemsId: String,
                            id: String,
                            data: [String : Any]) -> Item
    {
        return Item(itemsId: itemsId,
                    id: id,
                    title: data[Keys.title.rawValue] as! String,
                    done: data[Keys.done.rawValue] as! Bool,
                    authorId: data[Keys.author_id.rawValue] as! String)
    }
}
