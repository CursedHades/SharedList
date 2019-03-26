//
//  ProposalManger.swift
//  SharedList
//
//  Created by Lukasz on 24/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation
import Firebase
import MulticastDelegateSwift


protocol ProposalManagerDelegate : class {
    func ProposalAdded()
    func ProposalRemoved()
}

extension ProposalManagerDelegate {
    func ProposalRemoved() {}
}

class ProposalManager {
    
    let delegates = MulticastDelegate<ProposalManagerDelegate>()
    
    var proposals = [Proposal]()
    
    fileprivate var observers = [DataEventType: DatabaseHandle?]()
    fileprivate var activeObservers = 0
    
    fileprivate let listManager : ListManager
    
    init(listManager: ListManager) {
        self.listManager = listManager
    }
    
    func LoadData() {
        
        let userId = Auth.auth().currentUser!.uid
        let userPorposalsDbRef = Database.database().reference().child("users/\(userId)/proposals")
        
        let query = userPorposalsDbRef.queryOrderedByKey()
        
        query.observeSingleEvent(of: .value) { (proposalSnapshot) in
            
            let proposalsDict = proposalSnapshot.value as! [String : Any]
            
            for (listId , userData) in proposalsDict {
                
                if let dataDict = userData as? [String : String] {
                    if let proposal = Proposal.Deserialize(listId: listId, data: dataDict) {
                        self.proposals.append(proposal)
                    }
                }
            }
            
            self.delegates.invokeDelegates({ (delegate) in
                delegate.ProposalAdded()
            })
        }
    }
    
    func ActivateObservers() {
        
        activeObservers = activeObservers + 1
        
        if (observers[.childAdded] == nil) {
            
            let userId = Auth.auth().currentUser!.uid
            let userPorposalsDbRef = Database.database().reference().child("users/\(userId)/proposals")
            
            observers[.childAdded] = userPorposalsDbRef.observe(.childAdded)
            { (proposalSnapshot) in
                
                let listId = proposalSnapshot.key
                
                for proposal in self.proposals {
                    if (proposal.list_id == listId) {
                        return
                    }
                }
                
                let dataDict = proposalSnapshot.value as! [String : String]
                
                if let proposal = Proposal.Deserialize(listId: listId, data: dataDict) {
                    
                    self.proposals.append(proposal)
                    
                    self.delegates.invokeDelegates({ (delegate) in
                        delegate.ProposalAdded()
                    })
                }
            }
        }
        
        if (observers[.childRemoved] == nil) {
            let userId = Auth.auth().currentUser!.uid
            let userPorposalsDbRef = Database.database().reference().child("users/\(userId)/proposals")
            
            observers[.childRemoved] = userPorposalsDbRef.observe(.childRemoved, with:
            { (proposalSnapshot) in
                
                for (index, proposal) in self.proposals.enumerated() {
                    
                    if (proposal.list_id == proposalSnapshot.key) {
                        
                        self.proposals.remove(at: index)
                        
                        self.delegates.invokeDelegates({ (delegate) in
                            delegate.ProposalRemoved()
                        })
                        
                        return
                    }
                }
            })
        }
    }
    
    func DeactivateObservers()
    {
        if (activeObservers == 0) { fatalError("No active observers.") }
        
        activeObservers = activeObservers - 1
        
        if (activeObservers == 0) {
            
            let userId = Auth.auth().currentUser!.uid
            let userPorposalsDbRef = Database.database().reference().child("users/\(userId)/proposals")
            
            userPorposalsDbRef.removeAllObservers()
            observers.removeAll()
        }
    }
    
    func SendProposal(destinationUserEmail: String, listId: String, message: String) {
        
        let dbRef = Database.database().reference().root
        
        let query = dbRef.child("users").queryOrdered(byChild: "email").queryEqual(toValue: destinationUserEmail)
        
        query.observeSingleEvent(of: .value)
        { (snapshot) in
            
            let snapshotDict = snapshot.value as! [String : Any]
            let destinationUserId = snapshotDict.keys.first
            
            let proposalDbRef = dbRef.child("users/\(destinationUserId!)/proposals/\(listId)")
            
            let myEmail = Auth.auth().currentUser?.email
            
            let dataDict = [Proposal.Keys.user_email.rawValue : myEmail!,
                            Proposal.Keys.message.rawValue : message]
            
            proposalDbRef.setValue(dataDict)
        }
    }
    
    func AcceptProposal(_ proposal: Proposal) {
        
        let userId = Auth.auth().currentUser?.uid
        let listId = proposal.list_id
        
        let data = ["users/\(userId!)/lists/\(listId)" : true]
        
        Database.database().reference().updateChildValues(data) { (error, _) in
            self.RemoveProposal(proposal)
        }
    }
    
    func RemoveProposal(_ proposal: Proposal) {
        
        let userId = Auth.auth().currentUser?.uid
        let proposalId = proposal.list_id
        
        let updateData = ["users/\(userId!)/proposals/\(proposalId)": NSNull()]
        
        Database.database().reference().updateChildValues(updateData)
    }
    
    func GetListNameForProposal(_ proposal: Proposal, CompletionHandler: @escaping (_ name: String?) -> Void) {
        
        listManager.GetListById(proposal.list_id) { (returnedList) in
            
            if let list = returnedList {
                CompletionHandler(list.title)
            }
            else {
                // List does not exist anymore, remove invitation
                CompletionHandler(nil)
                self.RemoveProposal(proposal)
            }
        }
    }
}
