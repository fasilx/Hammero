//
//  Messages.swift
//  Hammero
//
//  Created by fasil fikreab on 1/21/15.
//  Copyright (c) 2015 fasil fikreab. All rights reserved.
//

import UIKit

class Messages {
    
    var messages = NSDictionary()
    var indexArray = NSArray()
    
    init (){
        
    }

    
    func setMessages(messages : NSDictionary, indexArray: NSArray){
        self.messages = messages
        self.indexArray = indexArray
    }
    
    func getMessages() -> NSDictionary {

        return self.messages
    }
    
    func getIndexArray() -> NSArray{
        return self.indexArray
    }
  

}
