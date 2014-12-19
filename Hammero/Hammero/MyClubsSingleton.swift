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
    
    
    func setClub (club: AnyObject   ) {
        self.club = club
    }
    
    func   getClub () -> AnyObject {
        
        return self.club
    }
    
    
   
}
