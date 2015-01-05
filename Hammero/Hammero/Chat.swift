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
    var currentSectionHeight: CGFloat = 0
    
    
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
                    temp[6] = message.valueForKeyPath("sender.auth.uid")!
                    
                    self.recievedMessages.addObject(temp)
                    self.collectionView?.reloadData()
                    
                    let x = sortedMessageKeys.count
                    let y = self.recievedMessages.count
                    
                    
                    if(x == y){
                        
                        // collectionview done reloading data, send noticicatin
                        //println("ready to send notification")
                        let doneReloading = NSNotificationCenter.defaultCenter()
                        doneReloading.postNotificationName("doneReloading", object: self, userInfo: nil)
                    }
                    
                    
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
    
    func sectionHeight(height: Int) -> CGFloat{
        
        return self.currentSectionHeight
    }
    
    func collectionView(minimumLineSpacingForSectionAtIndex: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 4
    }
    
    
 
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer", forIndexPath: indexPath) as UICollectionReusableView
        
        
        footer.backgroundColor  = UIColor.blueColor()
        
        
        return footer
    }

    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
        
   
    }
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
//        return CGSizeMake(self.collectionView.frame.width,  self.currentSectionHeight)
//    }
//    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let messageCell = collectionView.dequeueReusableCellWithReuseIdentifier("MessageCell", forIndexPath: indexPath) as UICollectionViewCell
        let avatarCell = collectionView.dequeueReusableCellWithReuseIdentifier("AvatarCell", forIndexPath: indexPath) as UICollectionViewCell
        let imageCell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as UICollectionViewCell
      
        
        
                messageCell.layer.borderWidth = 2
                messageCell.layer.borderColor = UIColor.redColor().CGColor
        
        
                avatarCell.layer.borderWidth = 2
                avatarCell.layer.borderColor = UIColor.redColor().CGColor
        
        
        
                imageCell.layer.borderWidth = 2
                imageCell.layer.borderColor = UIColor.redColor().CGColor
        
        
    
        
        
        
        
        let messageText = self.recievedMessages[indexPath.section][0] as? String
        let senderEmail = self.recievedMessages[indexPath.section][2] as? String
        let senderPosition  = self.recievedMessages[indexPath.section][3] as? String
        
        let imageMessageString = self.recievedMessages[indexPath.section][1] as String
        let imageAvatarString = self.recievedMessages[indexPath.section][5] as String
        
        let ix = imageCell.frame.origin.x
        let ax = avatarCell.frame.origin.x
        let mx = avatarCell.frame.origin.x
    
        
        
        
        let sentTimeString =  self.recievedMessages[indexPath.section][4] as? String
        
        if(imageAvatarString != ""){
            
            let imageAvatarData = NSData(base64EncodedString: imageAvatarString, options: .allZeros)
            let imageAvatar = UIImage(data: imageAvatarData!)
            var avatarView = UIImageView(frame: CGRectZero)//CGRectMake(messageCell.frame.origin.x, messageCell.frame.origin.y, 0, 0))
            avatarCell.addSubview(avatarView)
            avatarView.image = imageAvatar
            avatarView.frame.size = CGSizeMake(50, 50)
            
            avatarCell.frame.size = avatarView.frame.size
            avatarView.layer.borderWidth = 0.5
            avatarView.layer.borderColor = UIColor.lightGrayColor().CGColor
            avatarView.layer.cornerRadius =  avatarView.frame.size.width/2
            
            
        }else{
            avatarCell.frame.size = CGSizeZero
        }
        
        if(imageMessageString != ""){
            
            let imageMessageData = NSData(base64EncodedString: imageMessageString, options: .allZeros)
            let imageMessage = UIImage(data: imageMessageData!)
            
            var imageView = UIImageView( frame: CGRectZero) //frame: CGRectMake(messageCell.frame.origin.x, messageCell.frame.origin.y, 100, 100))
            imageView.image = imageMessage
            imageCell.addSubview(imageView)
            
            imageView.frame.size = CGSizeMake(100, 100)
            
            imageCell.frame.size = imageView.frame.size
            //            imageView.layer.borderWidth = 1
            //            imageView.layer.borderColor = UIColor.redColor().CGColor
            imageView.layer.cornerRadius = imageView.frame.size.width/8
            imageView.clipsToBounds = true
            
            
        }else{
            imageCell.frame.size = CGSizeZero
        }
        // imageCell.backgroundColor = UIColor.redColor()
        
        
       
        
        let dy = imageCell.frame.height
        messageCell.frame.offset(dx: 0, dy: dy)
        imageCell.frame.offset(dx: -ix, dy: 0)
        
  
        
        
       // self.currentSectionHeight   = messageCell.frame.height + imageCell.frame.height
      println(self.currentSectionHeight)
      
        //collectionView.collectionViewLayout.
        
        
        
        
        var messageView = UITextView(frame: CGRectZero)//CGRectMake(messageCell.frame.origin.x, messageCell.frame.origin.y, 0, 0))
        
        messageCell.addSubview(messageView)
        messageView.text = messageText
        messageView.sizeToFit()
        
        messageCell.frame.size = messageView.frame.size
        //        messageView.layer.borderWidth = 1
        //        messageView.layer.borderColor = UIColor.redColor().CGColor
        messageView.backgroundColor = UIColor.greenColor()
        messageView.layer.cornerRadius = messageView.frame.size.height/8
        
        
        
        
        
        if(imageAvatarString != ""){
            
            let imageAvatarData = NSData(base64EncodedString: imageAvatarString, options: .allZeros)
            let imageAvatar = UIImage(data: imageAvatarData!)
            var avatarView = UIImageView(frame: CGRectZero)//CGRectMake(messageCell.frame.origin.x, messageCell.frame.origin.y, 0, 0))
            avatarCell.addSubview(avatarView)
            avatarView.image = imageAvatar
            avatarView.frame.size = CGSizeMake(50, 50)
            
            avatarCell.frame.size = avatarView.frame.size
            avatarView.layer.borderWidth = 0.5
            avatarView.layer.borderColor = UIColor.lightGrayColor().CGColor
            avatarView.layer.cornerRadius =  avatarView.frame.size.width/2
            
            
        }else{
            avatarCell.frame.size = CGSizeZero
        }
        
        if(imageMessageString != ""){
            
            let imageMessageData = NSData(base64EncodedString: imageMessageString, options: .allZeros)
            let imageMessage = UIImage(data: imageMessageData!)
            
            var imageView = UIImageView( frame: CGRectZero) //frame: CGRectMake(messageCell.frame.origin.x, messageCell.frame.origin.y, 100, 100))
            imageView.image = imageMessage
            imageCell.addSubview(imageView)
            
            imageView.frame.size = CGSizeMake(100, 100)
            
            imageCell.frame.size = imageView.frame.size
            //            imageView.layer.borderWidth = 1
            //            imageView.layer.borderColor = UIColor.redColor().CGColor
            imageView.layer.cornerRadius = imageView.frame.size.width/8
            imageView.clipsToBounds = true
            
            
        }else{
            imageCell.frame.size = CGSizeZero
        }
        // imageCell.backgroundColor = UIColor.redColor()
        
        
        collectionView.sizeToFit()
        
        if(indexPath.item == 0){
            return messageCell
        }else if (indexPath.item == 1) {
            return avatarCell
        }else{
            return imageCell
        }
    }
}
