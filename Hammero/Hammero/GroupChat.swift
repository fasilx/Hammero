//
//  GroupChat.swift
//  Hammero
//
//  Created by fasil fikreab on 12/7/14.
//  Copyright (c) 2014 fasil fikreab. All rights reserved.
//


import UIKit
import Foundation


class GroupChat: UIViewController, UIScrollViewDelegate
{
    var user:FAuthData? = nil
    var club: AnyObject = [:]
    var ref = Firebase(url: "https://peopler.firebaseio.com")
    
    var scrollerHeight: CGFloat = 0.0
    
    
    
    @IBOutlet var scroller: UIScrollView!
    
    var recievedMessages = NSMutableArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let instance = MyClubsSingleton.sharedInstance
        self.club = instance.getClub()
        
        // println(ref)
        
        self.checkAuth()
        
        
    }
    
    func checkAuth(){
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated with Firebase
                self.user = authData
                self.setupFirebase()
                
            } else {
                self.performSegueWithIdentifier("checkAuth", sender: self)
            }
        })
    }
    
    
    
    func  setupFirebase(){
        
        let clubID = self.club.valueForKey("clubID") as String
        var messageLimitedTo: UInt = 20
        
        ref.childByAppendingPath("/messages/" + clubID + "/all").queryLimitedToLast(messageLimitedTo).observeEventType(.Value, withBlock: {
            dataSnapshot in
            
            
            
            if(dataSnapshot.value as NSObject == NSNull()){
                println("it is null")
                
                let notice = UILabel(frame: CGRectMake(5, self.view.bounds.height/3, 0, 0))
                notice.text = "  There are no conversations started yet  "
                notice.sizeToFit()
                notice.adjustsFontSizeToFitWidth = true
                notice.layer.borderColor = UIColor.redColor().CGColor
                notice.layer.borderWidth = 0.5
                self.view.addSubview(notice)
                return;
                
            }
            
            var messagesDictionary = dataSnapshot.value as NSMutableDictionary
            
            // Dictionary does not have a guarenteed order. Arrays do. So chane to arrary and sort here
            let unsortedMessages = messagesDictionary.allKeys
            let sortedMessageKeys =  unsortedMessages.sorted({ (s1, s2) -> Bool in
                s2 as String > s1 as String
            })
            
            
            /////////////////////////////BEGIN FOR LOOP/////////////////////////////////////////// one loop is one cell, just like in UITableViewCells
            
            var cellHeight: CGFloat = 30
            
            
            for aKey in sortedMessageKeys {
                
                let message = messagesDictionary.valueForKey(aKey as String) as NSMutableDictionary
                let uid = message.valueForKeyPath("sender.auth.uid") as NSString
                let messageText = message.valueForKeyPath("message.message") as String
                let messageImageString =  message.valueForKeyPath("message.image") as? String
                let senderEmailText = message.valueForKeyPath("sender.password.email") as? String
                let senderPositionArray: NSArray = message.valueForKey("position") as NSArray
                let sentAt: AnyObject  =  message.valueForKey("createdAt")!
                let senderID = message.valueForKeyPath("sender.auth.uid") as String
                var avatarImageString = ""
               
                
                // firebase call to users
                self.ref.childByAppendingPath("/users/" + uid).observeEventType(.Value, withBlock: {
                    dataSnapshot in
                    let auth = dataSnapshot.value as NSDictionary
                    avatarImageString =  auth.valueForKey("avatar") as String
                    
                })
                
                
                
                let sideInset: CGFloat = self.view.bounds.width * 0.02
                let bottomInset: CGFloat = 10
                let padding: CGFloat = 12
                
                var messageViewY: CGFloat = 0
                var imageMessageHeight: CGFloat = 0
                var imageMessageWidth: CGFloat = 0
                
                // create views
                var messageView = UITextView()
                var imageMessageView = UIImageView()
                var avatarImageView = UIImageView()
                var senderEmailButton = UIButton()
                var senderPositionButton = UIButton()
                var sentAtLabel = UILabel()
                
                
                var messageTextStringLength = messageText.sizeWithAttributes(nil).width
                var maxMessageViewWidth = self.view.bounds.width * 0.8
                var numberOfLines = messageTextStringLength/maxMessageViewWidth // this is the number of lines required
                
                
                let messageViewHeight: CGFloat = (ceil(numberOfLines) + 1) * messageText.sizeWithAttributes(nil).height + padding
                
                // messageView. all View positions based on messageViewView
                if( messageTextStringLength > maxMessageViewWidth){
                    messageView = UITextView(frame: CGRectMake(sideInset, cellHeight, maxMessageViewWidth, messageViewHeight))
                    messageView.text = messageText
                    messageViewY = messageView.bounds.origin.y
                }else{
                    messageView = UITextView(frame: CGRectMake(sideInset, cellHeight, 0, 0))
                    messageView.text = messageText
                    messageView.sizeToFit()
                }
                
                messageView.layer.cornerRadius = messageView.bounds.height / 8  //20% of width
                self.view.addSubview(messageView)
                
    
                //avatarImageview
                
                let avatarImageWidth: CGFloat = 30
                let avatarImageHeight: CGFloat = 30
                let gabMessageViewToAvatar: CGFloat = 5
                    avatarImageView = UIImageView(frame: CGRectMake(sideInset, cellHeight, avatarImageWidth, avatarImageHeight))
                
                if(avatarImageString != "" && avatarImageString != " "){
    
                    let avatarData = NSData(base64EncodedString: avatarImageString, options: .allZeros)
                    avatarImageView.image = UIImage(data: avatarData!)
            
                }else{
                    avatarImageView.image = UIImage(named: "avatar-default")
                }
                
                
                avatarImageView.layer.cornerRadius = avatarImageWidth/2
                avatarImageView.layer.borderWidth = 0.5
                avatarImageView.layer.backgroundColor = UIColor.lightGrayColor().CGColor
                
                self.view.addSubview(avatarImageView)
                
                avatarImageView.transform.tx = messageView.frame.width + gabMessageViewToAvatar
                avatarImageView.transform.ty = messageView.frame.height - avatarImageHeight
                
                
                // lables
                let verticalSpacing : CGFloat = 5
                let labelPlacing = messageView.frame.height + verticalSpacing
                let horizontalLabelSpacing: CGFloat = 10
                
                senderEmailButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
                senderEmailButton.frame = CGRectMake(sideInset, cellHeight + labelPlacing, 0 , 0)
                senderEmailButton.setTitle(senderEmailText, forState: UIControlState.Normal)
                senderEmailButton.titleLabel?.font = UIFont.systemFontOfSize(11)
                senderEmailButton.sizeToFit()
                
                senderPositionButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
                senderPositionButton.frame = CGRectMake(sideInset, cellHeight +   labelPlacing, 0, 0)
                senderPositionButton.setTitle( senderPositionArray[0] as? NSString, forState: UIControlState.Normal)
                senderPositionButton.titleLabel?.font = UIFont.systemFontOfSize(11)
                senderPositionButton.sizeToFit()
                senderPositionButton.transform.tx = senderEmailButton.frame.width + horizontalLabelSpacing
               
                
            
                sentAtLabel = UILabel(frame: CGRectMake(sideInset, cellHeight, 0, 0)) // top of text view
                sentAtLabel.font = UIFont.systemFontOfSize(9)
                sentAtLabel.alpha = 0.7
                sentAtLabel.text = "today: 5:40PM"
                sentAtLabel.sizeToFit()
                sentAtLabel.transform.ty = -sentAtLabel.bounds.height
                
  
                
//                sentAtLabel.backgroundColor = UIColor.redColor()
//                senderPositionLabel.backgroundColor = UIColor.redColor()
//                senderEmailLabel.backgroundColor = UIColor.redColor()
//                
                self.view.addSubview(senderEmailButton)
                self.view.addSubview(sentAtLabel)
                self.view.addSubview(senderPositionButton)
                
                
//                println(senderEmailLabel)
//                println(sentAtText)
//                println(senderPositionText)
        
                
                // messageStringView.
                if(messageImageString != "" && messageImageString != " "){
                    
                    imageMessageHeight = 100
                    imageMessageWidth = 100
                    
                    imageMessageView = UIImageView(frame: CGRectMake(sideInset, cellHeight, imageMessageWidth, imageMessageHeight))
                    let imageData = NSData(base64EncodedString: messageImageString!, options: .allZeros)
                    
                    imageMessageView.image = UIImage(data: imageData!)
                    imageMessageView.layer.cornerRadius = imageMessageWidth/8
                    imageMessageView.clipsToBounds = true
                    
                    //move messageView down for imageMessageView, avatarView, and all labels
                    messageView.transform.ty = imageMessageHeight
                    avatarImageView.transform.ty = imageMessageHeight
                    senderEmailButton.transform.ty = imageMessageHeight
                    senderPositionButton.transform.ty = imageMessageHeight
            
                    
                    self.view.addSubview(imageMessageView)
                    
                }
                
                
                // Tarnsformation based on sender
                if(self.user?.uid == message.valueForKeyPath("sender.auth.uid") as? NSString){
                    
                    messageView.transform.tx = self.view.bounds.width - messageView.bounds.width - 2 * sideInset
                    imageMessageView.transform.tx = self.view.bounds.width - imageMessageView.bounds.width - 2 * sideInset
                    avatarImageView.transform.tx = self.view.bounds.width - messageView.bounds.width - 2 * avatarImageView.bounds.width + 2 * sideInset
                    senderEmailButton.transform.tx = self.view.bounds.width - 2 * senderEmailButton.frame.width
                    senderPositionButton.transform.tx = self.view.bounds.width - senderPositionButton.frame.origin.x + senderPositionButton.frame.width - 2 * sideInset
                    
                    // transform with the messageView
                    sentAtLabel.transform.tx = self.view.bounds.width - messageView.bounds.width - 2 * sideInset - (sentAtLabel.frame.width - messageView.bounds.width)
                    

                    messageView.backgroundColor = UIColor.greenColor()
                    
                    
                    
                }else{
                    
                    messageView.backgroundColor = UIColor.lightGrayColor()
                    
                }
                
                //add a dividing line
//                let line = UILabel(frame: CGRectMake(self.view.bounds.width * 0.25, cellHeight - bottomInset, self.view.bounds.width/2, 1))
//                line.backgroundColor = UIColor.lightGrayColor()
//                line.layer.cornerRadius = line.bounds.height/2
//                self.view.addSubview(line)
              
                // add cell height
                cellHeight = cellHeight + imageMessageHeight +  senderEmailButton.bounds.height + verticalSpacing +  messageView.bounds.height + bottomInset * 2
                
          
                
                
                
            }
            
            self.scrollerHeight = cellHeight
            ////////////////////////////END FOR LOOP//////////////////////////////////////////
            
            self.scroller.contentSize = CGSizeMake(self.view.bounds.width, self.scrollerHeight)
            self.scroller.scrollsToTop = true
            //scroll bottom
            self.scroller.setContentOffset(CGPointMake(0, self.scroller.contentSize.height - self.scroller.bounds.size.height), animated: false)
            
        })
        
        
        
    }
    
    
}