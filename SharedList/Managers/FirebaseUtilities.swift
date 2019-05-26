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
        
        return DbRef().child(UserPath(id))
    }
    
    static func UserListsDbRef() -> DatabaseReference {
        
        return UserDbRef().child("\(Keys.lists.rawValue)")
    }
    
    static func ListDbRef(_ id: String) -> DatabaseReference {
        
        return DbRef().child(ListPath(id))
    }
    
    static func ListUsersDbRef(_ id: String) -> DatabaseReference {
        return DbRef().child(ListUsersPath(id))
    }
    
    static func UserInListDbRef(listId: String, userId: String) -> DatabaseReference {
        return DbRef().child(UserInListPath(listId: listId, userId: userId))
    }
    
    static func ListsTableDbRef() -> DatabaseReference {
        
        return DbRef().child("\(Keys.lists.rawValue)")
    }
    
    static func ItemsTableDbRef() -> DatabaseReference {
        
        return DbRef().child("\(Keys.items.rawValue)")
    }
    
    static func ItemsDbRef(_ id: String) -> DatabaseReference {
        return ItemsTableDbRef().child(id)
    }
    
    // MARK: - String Paths Getters
    static func UserPath(_ id : String) -> String {
        return ("\(Keys.users.rawValue)/\(id)")
    }
    
    static func ListPath(_ id : String) -> String {
        return ("\(Keys.lists.rawValue)/\(id)")
    }
    
    static func ListUsersPath(_ id : String) -> String {
        return ("\(Keys.lists.rawValue)/\(id)/\(Keys.users.rawValue)")
    }
    
    static func ItemsTablePath(_ id : String) -> String {
        return ("\(Keys.items.rawValue)/\(id)")
    }
    
    static func ItemsInItemsPath(_ id : String) -> String {
        return ItemsTablePath(id) + ("/\(Items.Keys.items.rawValue)")
    }
    
    static func ItemPath(_ itemsId: String, _ itemId : String) -> String {
        return ItemsInItemsPath(itemsId) + ("/\(itemId)")
    }
    
    static func UserInListPath(listId: String, userId: String) -> String {
        return ListUsersPath(listId) + ("/\(userId)")
    }
}
