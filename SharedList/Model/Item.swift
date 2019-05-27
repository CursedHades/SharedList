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
        case author = "author"
        case done_by = "done_by"
    }
    
    let itemsId : String
    let id : String
    let author : String
    let doneBy : String
    private(set) var title : String
    private(set) var done : Bool
    
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
    
    init(itemsId: String, id:String, title: String, done: Bool, author: String, doneBy: String = "NONE")
    {
        self.itemsId = itemsId
        self.id = id
        self.title = title
        self.done = done
        self.author = author
        self.doneBy = doneBy
        
        self.frbPrefix = frb_utils.ItemPath(itemsId, id)
    }
    
    func Serialize() -> [String : Any]
    {
        var dict = [String : Any]()
        
        dict[Path(Keys.title)] = title
        dict[Path(Keys.done)] = done
        dict[Path(Keys.author)] = author
        dict[Path(Keys.done_by)] = doneBy
        
        return dict
    }
    
    func Path(_ key: Keys) -> String
    {
        return frbPrefix + "/\(key.rawValue)"
    }
    
    static func Deserialize(itemsId: String, id: String, data: [String : Any]) -> Item
    {
        return Item(itemsId: itemsId,
                    id: id,
                    title: data[Keys.title.rawValue] as! String,
                    done: data[Keys.done.rawValue] as! Bool,
                    author: data[Keys.author.rawValue] as! String,
                    doneBy: data[Keys.done_by.rawValue] as! String)
    }
}
