//
//  Invitation.swift
//  SharedList
//
//  Created by Lukasz on 24/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation

class Invitation {
    
    enum Keys : String {
        case user_email = "user"
        case list_id = "list_id"
        case dest_user_id = "dest_user_id"
        case sender_user_id = "sender_user_id"
    }
    
    let id : String
    let list_id : String
    let sender_user_id : String
    
    var list : List? = nil
    
    init(id: String,
         listId: String,
         senderUserId: String)
    {
        self.id = id
        self.list_id = listId
        self.sender_user_id = senderUserId
    }
    
    static func Deserialize(id: String, data: [String : Any]) -> Invitation
    {
        return Invitation(id: id,
                          listId: data[Keys.list_id.rawValue] as! String,
                          senderUserId: data[Keys.sender_user_id.rawValue] as! String)
    }
    
    static func Path(_ prefix: String, _ key: Keys) -> String
    {
        return prefix + "/\(key.rawValue)"
    }
    
    static func Serialize(id: String,
                          listId: String,
                          destUserId: String,
                          senderUserId: String) -> [String : Any]
    {
        let prefix = frb_utils.InvitationPath(id)
        
        var dict = [String : Any]()
        
        dict[Path(prefix, Keys.list_id)] = listId
        dict[Path(prefix, Keys.dest_user_id)] = destUserId
        dict[Path(prefix, Keys.sender_user_id)] = senderUserId
        
        return dict
    }
}
