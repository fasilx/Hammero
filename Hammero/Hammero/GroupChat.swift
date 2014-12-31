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
        
         var offSetHeight: CGFloat = 10
         
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

            
            for aKey in sortedMessageKeys {
                
                var auth = NSDictionary()
                var displayName = NSString()
              
                let message = messagesDictionary.valueForKey(aKey as String) as NSMutableDictionary
                
                let uid = message.valueForKeyPath("sender.auth.uid") as NSString
                
                // firebase call to users
                self.ref.childByAppendingPath("/users/" + uid).observeEventType(.Value, withBlock: {
                    dataSnapshot in
                    auth = dataSnapshot.value as NSDictionary
                    displayName = auth.valueForKey("displayName") as NSString
                    println(displayName)
                    println("................")
                })
                
                
                let messageText = message.valueForKeyPath("message.message") as NSString
                let imageString = message.valueForKeyPath("message.image") as? String
              
                let offsetWidth = self.view.bounds.width * 0.98 // 30 percent from minX of View
                
                let imageHeight: CGFloat = 100
                let imageWidth: CGFloat = -100
                
                let gap: CGFloat = 10
 
                var messageView = UITextView()
                var displayNameView = UITextView()
                
                if( messageText.sizeWithAttributes(nil).width > self.view.bounds.width * 0.80){
                    
                    var x = messageText.sizeWithAttributes(nil).width
                    var y = self.view.bounds.width * 0.8
                    var z = x/y // this is the number of lines required
                    var padding: CGFloat = 12
                    let textBoxHeight = (ceil(z) + 1) * messageText.sizeWithAttributes(nil).height + padding
                
                    messageView = UITextView(frame: CGRectMake(offsetWidth, offSetHeight, self.view.bounds.width * 0.80, textBoxHeight))
                    messageView.text = messageText
                    
                    displayNameView = UITextView(frame: CGRectMake(offsetWidth, offSetHeight + textBoxHeight + 2, self.view.bounds.width * 0.80, textBoxHeight))
                    displayNameView.text = "my name is not y9ur"
                    
                    displayNameView.sizeToFit()
                    
                }else{
                    messageView = UITextView(frame: CGRectMake(offsetWidth, offSetHeight, 0, 0))
                    messageView.text = messageText
                    messageView.sizeToFit()
                    
                    displayNameView = UITextView(frame: CGRectMake(offsetWidth, (2 * offSetHeight + 2), 0, 0))
                    displayNameView.text = "My name is you"
                    displayNameView.sizeToFit()
                    
                  
                }
                
                
                
                messageView.layer.cornerRadius = messageView.bounds.height / 8  //20% of width
                
               
                if(self.user?.uid == message.valueForKeyPath("sender.auth.uid") as? NSString){
                    messageView.transform.tx = -messageView.bounds.width
                    displayNameView.transform.tx = -messageView.bounds.width
                    messageView.backgroundColor = UIColor.greenColor()
                     displayNameView.backgroundColor = UIColor.redColor()
                
                }else{
                    messageView.transform.tx = -offsetWidth*0.95
                    displayNameView.transform.tx = -offsetWidth*0.95
                    messageView.backgroundColor = UIColor.lightGrayColor()
                    displayNameView.backgroundColor = UIColor.redColor()
                }

               
                
                
                if(imageString != ""){
                    
                    let imageVeiw = UIImageView(frame: CGRectMake(offsetWidth, offSetHeight, imageWidth, imageHeight))
                    let imageData = NSData(base64EncodedString: imageString!, options: .allZeros)
                    
                    imageVeiw.image = UIImage(data: imageData!)
                    messageView.transform.ty = imageHeight
                    displayNameView.transform.ty = imageHeight
                    self.view.addSubview(imageVeiw)

                    
                    
                    offSetHeight = offSetHeight + imageHeight +  messageView.bounds.height + gap
                    
                }else{
                    offSetHeight = offSetHeight + messageView.bounds.height + gap
                }
               
                self.view.addSubview(messageView)
                self.view.addSubview(displayNameView)

                
                self.scrollerHeight = offSetHeight
                
              
            
            }
            
             self.scroller.contentSize = CGSizeMake(self.view.bounds.width, self.scrollerHeight)
             self.scroller.scrollsToTop = true
            //scroll bottom
            self.scroller.setContentOffset(CGPointMake(0, self.scroller.contentSize.height - self.scroller.bounds.size.height), animated: false)
            
            })
        
        
        
        }


}