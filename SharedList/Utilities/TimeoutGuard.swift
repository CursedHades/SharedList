//
//  TimeoutGuard.swift
//  SharedList
//
//  Created by Lukasz on 25/03/2019.
//  Copyright © 2019 Lukasz. All rights reserved.
//

import Foundation

protocol TimeoutGuardDelegate {
    
    func TimeoutGuardFired()
}

class TimeoutGuard {
    
    var isActive : Bool = false
    var delegate : TimeoutGuardDelegate? = nil
    
    private var timer : Timer? = nil
    
    func Activate() {
        
        Deactivate()
        
        isActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { (tm) in
            
            if let del = self.delegate {
                del.TimeoutGuardFired()
            }
            
            self.Deactivate()
        })
    }
    
    func Deactivate() {
        
        if let tm = timer {
            
            if (tm.isValid) {
                tm.invalidate()
            }
            timer = nil
        }
        
        isActive = false
    }
}
