//
//  Proposal.swift
//  SharedList
//
//  Created by Lukasz on 24/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation

class Proposal {
    
    enum Keys : String {
        case user_email = "user"
        case message = "message"
    }
    
    let list_id : String
    let user_email : String
    let message : String
    
    init(listId: String, userEmail: String, message: String)
    {
        self.list_id = listId
        self.user_email = userEmail
        self.message = message
    }
    
    static func Deserialize(listId: String, data: [String : String]) -> Proposal? {
        
        if let userEmail = data[Keys.user_email.rawValue] {
            if let message = data[Keys.message.rawValue] {
                return Proposal(listId: listId, userEmail: userEmail, message: message)
            }
        }
        
        return nil
    }
}
