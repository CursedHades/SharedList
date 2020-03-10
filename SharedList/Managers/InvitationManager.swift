//
//  InvitationManager.swift
//  SharedList
//
//  Created by Lukasz on 30/06/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Firebase
import MulticastDelegateSwift

protocol ShareListManagerDelegate : class {
    func InvitationSent()
}

class ShareListManager {
    
    weak var delegate : ShareListManagerDelegate?
    
    func Share(destUserEmail: String, message: String, listId: String)
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
            let destUserId = snapshotDict.keys.first!
            let currentUserId = Auth.auth().currentUser!.uid
            
            let newInvitationKey = frb_utils.InvitationsTableDbRef().childByAutoId().key!
            var updateData = Invitation.Serialize(id:newInvitationKey,
                                                  listId: listId,
                                                  destUserId: destUserId,
                                                  senderUserId: currentUserId)
            
            updateData[frb_utils.InvitationInUserPath(newInvitationKey, destUserId)] = true
            
            frb_utils.DbRef().updateChildValues(updateData)
            { (error, snapshot) in
                self.NotifyDelegate()
            }
        }
    }
    
    func Remove(userId: String, invitationId: String, completion: @escaping () -> Void)
    {
        let updateData = [frb_utils.InvitationPath(invitationId): NSNull(),
                          frb_utils.InvitationInUserPath(invitationId, userId): NSNull() ] as [String : Any]
        
        frb_utils.DbRef().updateChildValues(updateData)
        { (error, snapshot) in
            completion()
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







protocol InvitationManagerDelegate : class {
    func InvitationAdded()
    func InvitationRemoved()
    func UserAddedToList()
}

class InvitationManager {
    
    let delegates = MulticastDelegate<InvitationManagerDelegate>()
    
    var invitations = [Invitation]()
    
    fileprivate let observersHandler : ObserversHandler
    fileprivate var observerActive : Bool = false
    fileprivate let listsManager : ListsManager
    
    init(listsManager: ListsManager)
    {
        self.listsManager = listsManager
        
        let userId = Auth.auth().currentUser!.uid
        let invitationsDbRef = frb_utils.UserInvitationsDbRef(userId)
        self.observersHandler = ObserversHandler(invitationsDbRef)
        
        ActivateObservers()
    }
    
    func HasInvitation() -> Bool
    {
        return !invitations.isEmpty
    }
    
    func ActivateObservers()
    {
        if (observerActive == false)
        {
            observerActive = true
            observersHandler.AddObserver(eventType: .childAdded, InvitationsChildAdded)
            observersHandler.AddObserver(eventType: .childRemoved, InvitationsChildRemoved)
        }
    }
    
    // MARK: - Invitations Observers Handlers
    fileprivate func InvitationsChildAdded(_ invitationSnapshot: DataSnapshot)
    {
        let invitationId = invitationSnapshot.key
        self.LoadInvitation(id: invitationId)
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
    
    fileprivate func LoadInvitation(id: String)
    {
        let invitationDbRef = frb_utils.InvitationDbRef(id)
        invitationDbRef.observeSingleEvent(of: .value)
        { (invitationSnapshot) in
            if let invitationDict = invitationSnapshot.value as? [String : Any]
            {
                let newInvitation = Invitation.Deserialize(id: id,
                                                           data: invitationDict)
                self.invitations.append(newInvitation)
                
                self.delegates.invokeDelegates()
                    { (delegate) in
                        delegate.InvitationAdded()
                }
            }
        }
    }
    
    func RemoveInvitation(at index: Int)
    {
        let invitation = invitations[index]
        let userId = Auth.auth().currentUser?.uid
        
        self.invitations.remove(at: index)
        
        ShareListManager().Remove(userId: userId!,
                                  invitationId: invitation.id)
        {
            self.delegates.invokeDelegates()
            { (delegate) in
                delegate.InvitationRemoved()
            }
        }
    }
    
    func AcceptInvitation(at index: Int)
    {
        if let list = invitations[index].list
        {
            listsManager.AddCurrentUserToList(list: list)
            {
                self.RemoveInvitation(at: index)
                
                self.delegates.invokeDelegates()
                { (delegate) in
                    delegate.UserAddedToList()
                }
            }
        }
    }
    
    func GetListForInvitation(index: Int, CompletionHandler: @escaping (_ list: List?) -> Void)
    {
        let invitation = invitations[index]
        listsManager.GetListById(invitation.list_id)
        { (returnedList) in
            if let list = returnedList
            {
                invitation.list = list
                CompletionHandler(list)
            }
            else
            {
                // List does not exist anymore, remove invitation
                CompletionHandler(nil)
                self.RemoveInvitation(at: index)
            }
        }
    }
}
