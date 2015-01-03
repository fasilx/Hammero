//
//  Chat.swift
//  Hammero
//
//  Created by fasil fikreab on 12/30/14.
//  Copyright (c) 2014 fasil fikreab. All rights reserved.
//

import UIKit


class Chat: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    var user:FAuthData? = nil
    var club: AnyObject = [:]
    var ref = Firebase(url: "https://peopler.firebaseio.com")
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var recievedMessages: NSMutableArray =  []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.collectionView.dataSource = self
        self.collectionView?.delegate = self
        
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
                // println("it is null")
                
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
            
            
            for aKey in sortedMessageKeys {
                
                let message = messagesDictionary.valueForKey(aKey as String) as NSMutableDictionary
                
                let temp = NSMutableArray()
                
                let uid = message.valueForKeyPath("sender.auth.uid") as NSString
                
                self.ref.childByAppendingPath("/users/" + uid).observeEventType(.Value, withBlock: {
                    dataSnapshot in
                    let auth = dataSnapshot.value as NSDictionary
                    
                    temp[0] = message.valueForKeyPath("message.message")!
                    temp[1] =  message.valueForKeyPath("message.image")!
                    temp[2] = message.valueForKeyPath("sender.password.email")!
                    temp[3] = message.valueForKey("position")!
                    temp[4] =  message.valueForKey("createdAt")!
                    temp[5] =  auth.valueForKey("avatar")!
                    
                    self.recievedMessages.addObject(temp)
                    self.collectionView?.reloadData()
                    
                    //                     let x = sortedMessageKeys.count
                    //                     let y = self.recievedMessages.count
                    //
                    //
                    //                    if(x == y){
                    //
                    //                        // collectionview done reloading data, send noticicatin
                    //                        //println("ready to send notification")
                    //                        let doneReloading = NSNotificationCenter.defaultCenter()
                    //                        doneReloading.postNotificationName("doneReloading", object: self, userInfo: nil)
                    //                    }
                    
                    
                })
                // println(self.recievedMessages.count)
                
            }
            
            
        })
        
        
        
    }
    
    
    
    
    // Mark:- Collection View
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        
        return self.recievedMessages.count
    }
    
    
    
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let messageCell = collectionView.dequeueReusableCellWithReuseIdentifier("MessageCell", forIndexPath: indexPath) as UICollectionViewCell
        let avatarCell = collectionView.dequeueReusableCellWithReuseIdentifier("AvatarCell", forIndexPath: indexPath) as UICollectionViewCell
        let imageCell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as UICollectionViewCell
        
        let messageText = self.recievedMessages[indexPath.section][0] as? String
        let senderEmail = self.recievedMessages[indexPath.section][2] as? String
        let senderPosition  = self.recievedMessages[indexPath.section][3] as? String
        
        let imageMessageString = self.recievedMessages[indexPath.section][1] as String
        let imageAvatarString = self.recievedMessages[indexPath.section][5] as String
     
        
        
        let sentTimeString =  self.recievedMessages[indexPath.section][4] as? String
        
        var messageView = UITextView(frame: CGRectZero)//CGRectMake(messageCell.frame.origin.x, messageCell.frame.origin.y, 0, 0))
        messageCell.addSubview(messageView)
        messageView.text = messageText
        messageView.sizeToFit()
        
        messageCell.frame.size = messageView.frame.size
        messageView.layer.borderWidth = 1
        messageView.layer.borderColor = UIColor.redColor().CGColor
        messageView.backgroundColor = UIColor.greenColor()
        
        
        
        if(imageAvatarString != ""){
            
            let imageAvatarData = NSData(base64EncodedString: imageAvatarString, options: .allZeros)
            let imageAvatar = UIImage(data: imageAvatarData!)
            var avatarView = UIImageView(frame: CGRectZero)//CGRectMake(messageCell.frame.origin.x, messageCell.frame.origin.y, 0, 0))
            avatarCell.addSubview(avatarView)
            avatarView.image = imageAvatar
            avatarView.frame.size = CGSizeMake(50, 50)
            
            avatarCell.frame.size = avatarView.frame.size
            avatarView.layer.borderWidth = 1
            avatarView.layer.borderColor = UIColor.blueColor().CGColor
            avatarView.layer.cornerRadius = 25
        }
        
        
        if(imageMessageString != ""){

            let imageMessageData = NSData(base64EncodedString: imageMessageString, options: .allZeros)
            let imageMessage = UIImage(data: imageMessageData!)
            
            var imageView = UIImageView( frame: CGRectZero) //frame: CGRectMake(messageCell.frame.origin.x, messageCell.frame.origin.y, 100, 100))
            imageView.image = imageMessage
            imageCell.addSubview(imageView)
            
            imageView.frame.size = CGSizeMake(100, 100)
            
            imageCell.frame.size = imageView.frame.size
            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = UIColor.lightGrayColor().CGColor
            
        }
        // imageCell.backgroundColor = UIColor.redColor()
        
        
        
        
        
        if(indexPath.item == 0){
            return messageCell
        }else if (indexPath.item == 1) {
            return avatarCell
        }else{
            return imageCell
        }
    }
}
