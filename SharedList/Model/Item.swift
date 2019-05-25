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
    }
    
    let id : String
    private(set) var title : String
    private(set) var done : Bool
    
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
    
    fileprivate init(id:String, title: String, done: Bool)
    {
        self.id = id
        self.title = title
        self.done = done
    }
    
    static func Serialize(title: String, done: Bool) -> [String : Any]
    {
        var dict = [String : Any]()
        dict[Keys.title.rawValue] = title
        dict[Keys.done.rawValue] = done
        
        return dict
    }
    
    static func Deserialize(id: String, data: [String : Any]) -> Item
    {
        return Item(id: id,
                    title: data[Keys.title.rawValue] as! String,
                    done: data[Keys.done.rawValue] as! Bool)
    }
}
