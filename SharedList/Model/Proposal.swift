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
    }
    
    let list_id : String
    let user_email : String
    
    init(listId: String, userEmail: String)
    {
        list_id = listId
        user_email = userEmail
    }
    
    static func Deserialize(listId: String, data: [String : String]) -> Proposal? {
        
        if let userEmail = data[Keys.user_email.rawValue] {
            return Proposal(listId: listId, userEmail: userEmail)
        }
        else {
            return nil
        }
    }
}
