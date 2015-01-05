//
//  ChatCell.swift
//  Hammero
//
//  Created by fasil fikreab on 1/2/15.
//  Copyright (c) 2015 fasil fikreab. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    
    @IBOutlet weak var textMessageView: UITextView!
    @IBOutlet weak var imageMessageView: UIImageView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var senderEmailLabel: UILabel!
    
    @IBOutlet weak var sentTimeLabel: UILabel!
    
    @IBOutlet weak var senderPositionLabel: UILabel!
    

    func setCell(messageText: String){
        println(messageText)
        self.textMessageView?.text = messageText
    }
    
}
