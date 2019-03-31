//
//  User.swift
//  SharedList
//
//  Created by Lukasz on 31/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

class User {
    
    enum Keys : String {
        case email = "email"
        case name = "name"
    }
    
    let id : String
    let name : String
    let email : String
    
    init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
    
    static func Deserialize(id: String, data: [String : Any]) -> User {
        
        return User(id: id,
                    name: data[Keys.name.rawValue] as! String,
                    email: data[Keys.email.rawValue] as! String)
    }
}
