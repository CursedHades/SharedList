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
    
    let list_id : String
    let user_email : String
    
    init(listId: String, userEmail: String)
    {
        self.list_id = listId
        self.user_email = userEmail
    }
    
    static func Deserialize(listId: String, data: [String : String]) -> Invitation? {
        
        if let userEmail = data[Keys.user_email.rawValue] {
            return Invitation(listId: listId, userEmail: userEmail)
        }
        
        return nil
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
