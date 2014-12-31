//
//  Chat.swift
//  Hammero
//
//  Created by fasil fikreab on 12/30/14.
//  Copyright (c) 2014 fasil fikreab. All rights reserved.
//

import UIKit

class Chat: UICollectionViewController {
    
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
    
    var recievedMessages: NSMutableArray =  []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // println("something")
        
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
                   // println(self.recievedMessages)
                    
                })
                
            }
            
        })
        
        
        
    }
    
    
    
    
    // Mark:- Collection View
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        println(self.recievedMessages.count)

        return self.recievedMessages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as ChatCollectionCell
        return cell
    }
}
