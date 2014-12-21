//
//  MyClubsSingleton.swift
//  Hammero
//
//  Created by fasil fikreab on 12/18/14.
//  Copyright (c) 2014 fasil fikreab. All rights reserved.
//

import UIKit

class MyClubsSingleton: NSObject {
    

        class var sharedInstance : MyClubsSingleton {
            struct Singleton {
                static let instance = MyClubsSingleton()
            }
            return Singleton.instance
        }
        
    var club : AnyObject = [:]
    var row: Int = -1
    var clubModified : Bool = false
    
    
    func setClub (club: AnyObject, atRow: Int   ) {
        self.club = club
        self.row = atRow
    }
    
    func   getClub () -> AnyObject {
        
        return self.club
    }
    
    func setClubModification(modified: Bool){
        
        self.clubModified = modified
    }
    
    func getClubModification() -> Bool{
        return self.clubModified
    }
    
    func getRow() -> Int {
        return self.row
    }
    
    
   
}
