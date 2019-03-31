//
//  FirebaseUtilities.swift
//  SharedList
//
//  Created by Lukasz on 28/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase

class frb_utils {
    
    fileprivate enum Keys : String {
        case users = "users"
        case lists = "lists"
        case items = "items"
    }
    
    // MARK: - Reference Getters
    fileprivate static func DbRef() -> DatabaseReference {
        
        return Database.database().reference()
    }
    
    static func UserDbRef() -> DatabaseReference {
        
        let userId = Auth.auth().currentUser!.uid
        return DbRef().child(UserPath(userId))
    }
    
    static func UserDbRef(_ id: String) -> DatabaseReference {
        
        let userId = Auth.auth().currentUser!.uid
        return DbRef().child(UserPath(userId))
    }
    
    static func UserListsDbRef() -> DatabaseReference {
        
        return UserDbRef().child("\(Keys.lists.rawValue)")
    }
    
    static func ListDbRef(_ id: String) -> DatabaseReference {
        
        return DbRef().child(ListPath(id))
    }
    
    static func ListsDbRef() -> DatabaseReference {
        
        return DbRef().child("\(Keys.lists.rawValue)")
    }
    
    static func ItemsDbRef() -> DatabaseReference {
        
        return DbRef().child("\(Keys.items.rawValue)")
    }
    
    // MARK: - String Paths Getters
    static func UserPath(_ id : String) -> String {
        return ("\(Keys.users.rawValue)/\(id)")
    }
    
    static func ListPath(_ id : String) -> String {
        return ("\(Keys.lists.rawValue)/\(id)")
    }
    
    static func ItemsPath(_ id : String) -> String {
        return ("\(Keys.items.rawValue)/\(id)")
    }
}
