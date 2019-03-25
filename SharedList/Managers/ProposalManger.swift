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
}

class ProposalManager {
    
    let delegates = MulticastDelegate<ProposalManagerDelegate>()
    
    var proposals = [Proposal]()
    
    fileprivate var observers = [DataEventType: DatabaseHandle?]()
    fileprivate var activeObservers = 0
    
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
    
    func SendProposal(destinationUserEmail: String, listId: String) {
        
        let dbRef = Database.database().reference().root
        
        let query = dbRef.child("users").queryOrdered(byChild: "email").queryEqual(toValue: destinationUserEmail)
        
        query.observeSingleEvent(of: .value)
        { (snapshot) in
            
            let snapshotDict = snapshot.value as! [String : Any]
            let destinationUserId = snapshotDict.keys.first
            
            let proposalDbRef = dbRef.child("users/\(destinationUserId!)/proposals/\(listId)")
            
            let myEmail = Auth.auth().currentUser?.email
            
            let dataDict = ["user" : myEmail!]
            
            proposalDbRef.setValue(dataDict)
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
}
