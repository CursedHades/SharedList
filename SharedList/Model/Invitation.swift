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
}
