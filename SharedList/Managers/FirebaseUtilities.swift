//
//  FirebaseUtilities.swift
//  SharedList
//
//  Created by Lukasz on 28/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase

class frb_utils {
    
    enum Keys : String {
        case users = "users"
        case lists = "lists"
        case items = "items"
        case invitations = "invitations"
    }
    
    // MARK: - Reference Getters
    static func DbRef() -> DatabaseReference {
        
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
    
    static func UserInvitationsDbRef(_ id: String) -> DatabaseReference {
        
        return UserDbRef(id).child("\(Keys.invitations.rawValue)")
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
    
    static func UsersTableDbRef() -> DatabaseReference {
        return DbRef().child("\(Keys.users.rawValue)")
    }
    
    static func ItemsDbRef(_ id: String) -> DatabaseReference {
        return ItemsTableDbRef().child(id)
    }
    
    static func ItemDbRef(_ itemsId: String, _ itemId : String) -> DatabaseReference {
        return DbRef().child(ItemPath(itemsId, itemId))
    }
    
    static func InvitationsTableDbRef() -> DatabaseReference {
        return DbRef().child(Keys.invitations.rawValue)
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
    
    static func InvitationsTablePath() -> String {
        return ("\(Keys.invitations.rawValue)")
    }
    
    static func InvitationPath(_ id: String) -> String {
        return InvitationsTablePath() + ("/\(id)")
    }
    
    static func UserInvitationsPath(_ id: String) -> String {
        return UserPath(id) + ("/\(Keys.invitations.rawValue)")
    }
    
    static func InvitationInUserPath(_ invitationId: String, _ userId: String) -> String {
        return UserInvitationsPath(userId) + ("/\(invitationId)")
    }
}
