//
//  MyClubsCell.swift
//  Hammero
//
//  Created by fasil fikreab on 12/15/14.
//  Copyright (c) 2014 fasil fikreab. All rights reserved.
//

import UIKit

class MyClubsCell: UITableViewCell {


    @IBOutlet var clubName: UILabel!
    @IBOutlet var clubFounder: UILabel!
    @IBOutlet var clubDescription: UILabel!

    @IBOutlet var avatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        

        // Configure the view for the selected state
    }
    
    func setCell(clubName: String, clubDescription: String, clubFounder: String, avatar: UIImage){
        
        self.clubName.text = clubName
        self.clubFounder.text = clubFounder
        self.clubDescription.text = clubDescription
        self.avatar.image = avatar

        
        
    }
    

}
