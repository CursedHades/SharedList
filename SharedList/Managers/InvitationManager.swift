//
//  InvitationManager.swift
//  SharedList
//
//  Created by Lukasz on 30/06/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase
import MulticastDelegateSwift

protocol InvitationManagerDelegate : class {
    func InvitationAdded()
    func InvitationRemoved()
}

extension InvitationManagerDelegate {
    func InvitationRemoved() {}
}

protocol ShareListManagerDelegate : class {
    func InvitationSent()
}


class ShareListManager {
    
    weak var delegate : ShareListManagerDelegate?
    
    func Share(destUserEmail: String, listId: String)
    {
        let query = frb_utils.UsersTableDbRef().queryOrdered(byChild: User.Keys.email.rawValue).queryEqual(toValue: destUserEmail)
        
        query.observeSingleEvent(of: .value)
        { (snapshot) in
            
            if !snapshot.exists()
            {
                self.NotifyDelegate()
                return
            }
            
            let snapshotDict = snapshot.value as! [String : Any]
            let destUserId = snapshotDict.keys.first
            
            let invitationDbRef = frb_utils.UserInvitationsDbRef(destUserId!).child("/\(listId)")
            
            let myEmail = Auth.auth().currentUser?.email
            
            let dataDict = [Invitation.Keys.user_email.rawValue : myEmail!]
            
            invitationDbRef.setValue(dataDict)
            { (error, dfRef) in
                self.NotifyDelegate()
            }
        }
    }
    
    fileprivate func NotifyDelegate()
    {
        if let del = self.delegate
        {
            del.InvitationSent()
        }
    }
}



class InvitationManager {
    
    let delegates = MulticastDelegate<InvitationManagerDelegate>()
    
    var invitations = [Invitation]()
    
    fileprivate var observersHandler : ObserversHandler?
    
    fileprivate let listManager : ListsManager
    
    init(listManager: ListsManager) {
        self.listManager = listManager
    }
    
    fileprivate func InitObserverHandler() {
        let userId = Auth.auth().currentUser!.uid
        let userInvitationsDbRef = Database.database().reference().child("users/\(userId)/invitations")
        observersHandler = ObserversHandler(userInvitationsDbRef)
    }
    
    func LoadData() {
        
        let userId = Auth.auth().currentUser!.uid
        let userPorposalsDbRef = Database.database().reference().child("users/\(userId)/invitations")
        
        let query = userPorposalsDbRef.queryOrderedByKey()
        
        query.observeSingleEvent(of: .value) { (invitationsSnapshot) in
            
            if let invitationsDict = invitationsSnapshot.value as? [String : Any] {
                for (listId , userData) in invitationsDict {
                    
                    if let dataDict = userData as? [String : String] {
                        if let invitation = Invitation.Deserialize(listId: listId, data: dataDict) {
                            self.invitations.append(invitation)
                        }
                    }
                }
                
                self.delegates.invokeDelegates({ (delegate) in
                    delegate.InvitationAdded()
                })
            }
        }
    }
    
    func ActivateObservers() {
        
        if observersHandler == nil {
            InitObserverHandler()
        }
        
        observersHandler!.AddObserver(eventType: .childAdded, InvitationsChildAdded)
        observersHandler!.AddObserver(eventType: .childRemoved, InvitationsChildRemoved)
    }
    
    // MARK: - Invitations Observers Handlers
    fileprivate func InvitationsChildAdded(_ invitationSnapshot: DataSnapshot) {
        
        let listId = invitationSnapshot.key
        
        for invitation in self.invitations {
            if (invitation.list_id == listId) {
                return
            }
        }
        
        let dataDict = invitationSnapshot.value as! [String : String]
        
        if let invitation = Invitation.Deserialize(listId: listId, data: dataDict) {
            
            self.invitations.append(invitation)
            
            self.delegates.invokeDelegates({ (delegate) in
                delegate.InvitationAdded()
            })
        }
    }
    
    fileprivate func InvitationsChildRemoved(_ invitationSnapshot: DataSnapshot) {
        
        for (index, invitation) in self.invitations.enumerated() {
            
            if (invitation.list_id == invitationSnapshot.key) {
                
                self.invitations.remove(at: index)
                
                self.delegates.invokeDelegates({ (delegate) in
                    delegate.InvitationRemoved()
                })
                
                return
            }
        }
    }
    
    func AcceptInvitation(_ invitation: Invitation) {
        
        let userId = Auth.auth().currentUser?.uid
        let listId = invitation.list_id
        
        let data = ["users/\(userId!)/lists/\(listId)" : true]
        
        Database.database().reference().updateChildValues(data) { (error, _) in
            self.RemoveInvitation(invitation)
        }
    }
    
    func RemoveInvitation(_ invitation: Invitation) {
        
        let userId = Auth.auth().currentUser?.uid
        let invitationId = invitation.list_id
        
        let updateData = ["users/\(userId!)/invitations/\(invitationId)": NSNull()]
        
        Database.database().reference().updateChildValues(updateData)
    }
    
    func GetListNameForInvitation(_ invitation: Invitation, CompletionHandler: @escaping (_ name: String?) -> Void) {
        
        listManager.GetListById(invitation.list_id) { (returnedList) in
            
            if let list = returnedList {
                CompletionHandler(list.title)
            }
            else {
                // List does not exist anymore, remove invitation
                CompletionHandler(nil)
                self.RemoveInvitation(invitation)
            }
        }
    }
    
    fileprivate func Cleanup() {
        
        observersHandler = nil
        
        invitations.removeAll()
    }
}

// MARK : - AuthManagerDelegate
extension InvitationManager : AuthManagerDelegate {
    
    func UserLogedOut() {
        Cleanup()
    }
}
