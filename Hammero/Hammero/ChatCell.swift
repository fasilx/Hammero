//
//  ChatCell.swift
//  Hammero
//
//  Created by fasil fikreab on 1/2/15.
//  Copyright (c) 2015 fasil fikreab. All rights reserved.
//

import UIKit

class ChatCell: UICollectionViewCell {
    
    
    @IBOutlet weak var messageText: UITextView!
    
    @IBOutlet weak var messageImage: UIImageView!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var senderEmail: UILabel!
    
    @IBOutlet weak var sentTime: UILabel!
    
    @IBOutlet weak var senderPosition: UILabel!
    
  
 

    override init(frame: CGRect) {
        super.init(frame: CGRectMake(0, 0, 200, 110))
        
        
    }

    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    
}
