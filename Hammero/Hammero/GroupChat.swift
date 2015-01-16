//
//  GroupChat.swift
//  Hammero
//
//  Created by fasil fikreab on 12/7/14.
//  Copyright (c) 2014 fasil fikreab. All rights reserved.
//


import UIKit
import Foundation


class GroupChat: UIViewController, UITextViewDelegate
{
    var user:FAuthData? = nil
    var club: AnyObject = [:]
    var ref = Firebase(url: "https://peopler.firebaseio.com")
    
    var scrollerHeight: CGFloat = 0.0
    
    
  
    var senderView = UIView()
    var scroller = UIScrollView()
    var messageView =  UIView()
    
    var attachmentButton = UIButton()
    var sendButton = UIButton()
    var messageBox = UITextView()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let instance = MyClubsSingleton.sharedInstance
        self.club = instance.getClub()
        self.title = self.club.valueForKey("name") as? String
        self.checkAuth()
        
        self.messageBox.delegate = self
        

    }
    
    override func loadView() {
        // loadView should never call super
        
        self.view = UIView(frame: UIScreen.mainScreen().bounds)
        self.scroller = UIScrollView(frame: self.view.frame)
        self.scroller.addSubview(messageView)
        
        self.view.addSubview(self.scroller)
        
        self.scroller.backgroundColor = UIColor.whiteColor()
        
        
        self.setupSenderView()
               
    }
    
    
    
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView == messageBox){
            // placeholder replacement processing
            textView.text = ""
            textView.textColor = UIColor.blackColor()
            
            var length = countElements(textView.text)
            println(length)
            println("textViewDidBeginEditing")
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        if (textView == messageBox){

           // credit: http://stackoverflow.com/questions/3585470/how-to-read-number-of-lines-in-uitextview answer 2
          let rows = (textView.contentSize.height - textView.textContainerInset.top - textView.textContainerInset.bottom) / textView.font.lineHeight
            if(rows > 2){
                
                textView.sizeToFit()
                textView.layoutIfNeeded()
            }
            
        }
    }
    
    
    func  setupSenderView(){
        
        
        
        let sendeViewHeight: CGFloat = 60
        senderView = UIView(frame: CGRectMake(0, self.view.bounds.height - sendeViewHeight, self.view.bounds.width, sendeViewHeight))
        senderView.backgroundColor = UIColor.lightGrayColor()
        
        //postisions in senderView
        let inset: CGFloat = 4.0
        
        let positionX = CGPointMake(senderView.bounds.origin.x + inset, senderView.bounds.height/3)
        
        attachmentButton = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
        attachmentButton.frame.origin = positionX
        attachmentButton.transform.ty = 5
        //attachmentButton.setImage(UIImage(named: "camera-25"), forState: UIControlState.Normal)
        //attachmentButton.sizeToFit()
        
        
        sendButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        sendButton.center = positionX
        sendButton.setTitle("Send", forState: UIControlState.Normal)
        sendButton.sizeToFit()
        sendButton.transform.tx = senderView.frame.width - sendButton.frame.width - 2 * inset
        
        sendButton.addTarget(self, action: "sendMessage:", forControlEvents: UIControlEvents.TouchUpInside)
        
        messageBox.delegate = self
        let inputTextSize = "any text".sizeWithAttributes(nil).height * 2
        let messageFieldLength = senderView.frame.width - sendButton.frame.width - attachmentButton.frame.width - 4 * inset
        let numberOfLines: CGFloat = 1.0
        let messageBoxHeight = inputTextSize * numberOfLines
        messageBox.frame = CGRectMake(positionX.x, positionX.y, messageFieldLength, messageBoxHeight)
       
        messageBox.backgroundColor = UIColor.whiteColor()
        messageBox.layer.borderColor = UIColor.redColor().CGColor
        messageBox.layer.borderWidth = 1.0
        messageBox.layer.cornerRadius = messageView.bounds.width/8
       
        messageBox.transform.tx = attachmentButton.frame.width + inset
        messageBox.text = "Message"
        messageBox.textColor = UIColor.lightGrayColor() // get ride of these two lines in textfielddidStartEditng delegate
        
        //messageBox.contentOffset = CGPointMake(0, messageBox.frame.height)
       println(messageBox)
        
        
        senderView.addSubview(attachmentButton)
        senderView.addSubview(messageBox)
        senderView.addSubview(sendButton)
    
        
        self.view.addSubview(senderView)
        
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let keyboardNotification = NSNotificationCenter.defaultCenter()
        keyboardNotification.addObserver(self, selector: "keyboardWasShow:", name: UIKeyboardDidShowNotification, object: nil)
        keyboardNotification.addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func keyboardWasShow(note: NSNotification){
        
        let info = note.userInfo!
        let rect = info[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue()
        let keyboardHeight = rect.size.height

        senderView.frame.origin = CGPointMake(0, self.view.bounds.height - senderView.frame.size.height -  keyboardHeight)
        self.scroller.setContentOffset(CGPointMake(0, self.scroller.contentSize.height - self.scroller.bounds.size.height + keyboardHeight), animated: true)

    }
    
    func keyboardWillBeHidden(note: NSNotification){

        self.scroller.setContentOffset(CGPointMake(0, self.scroller.contentSize.height - self.scroller.bounds.size.height), animated: true)
        senderView.frame.origin = CGPointMake(0, self.view.bounds.height - senderView.frame.size.height)

    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
        self.scroller.endEditing(true)
       // println("end editin")
    }

    
    func sendMessage(sender: UIButton){
    
        let messageData = ["message": messageBox.text, "image": ""]
        let kFirebaseServerValueTimestamp = [".sv":"timestamp"]
        let position: [String] = ["FOUNDER"]
        
        let senderAuth = self.user?.valueForKey("auth")! as NSDictionary
        let senderPassword = self.user?.valueForKey("providerData")! as NSDictionary
        let sender = ["auth": senderAuth, "password": senderPassword]
     
        var  value = NSMutableDictionary()
        value.setValue(messageData, forKey: "message")
        value.setValue(kFirebaseServerValueTimestamp, forKey: "createdAt")
        value.setValue(position, forKey: "position")
        value.setValue(sender, forKey: "sender")
        
        //println(value)
        
        let clubID = self.club.valueForKey("clubID") as String
        
        ref.childByAppendingPath("/messages/" + clubID + "/all").childByAutoId().setValue(value, withCompletionBlock: {
            error, firbase in
            //println(error)
            //println(firbase)
            })
        
        self.messageBox.text = nil


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
            
          println(" went to get data")
            
            
            
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
            
        
         
            var messagesDictionary: NSMutableDictionary = dataSnapshot.value as NSMutableDictionary
            
           
            
            
            // Dictionary does not have a guarenteed order. Arrays do. So chane to arrary and sort here
            let unsortedMessages = messagesDictionary.allKeys
            let sortedMessageKeys: NSArray =  unsortedMessages.sorted({ (s1, s2) -> Bool in
                s2 as String > s1 as String
            })

            
            if(self.messageView.subviews.count > 0){
                
                for aView in self.messageView.subviews{
                    
                    aView.removeFromSuperview()
                }
            }
            
            /////////////////////////////BEGIN FOR LOOP/////////////////////////////////////////// one loop is one cell, just like in UITableViewCells
            
            var cellHeight: CGFloat = 30
            
            for keyIndex in 0...sortedMessageKeys.count - 1 {
                
                let message = messagesDictionary.valueForKey(sortedMessageKeys[keyIndex] as String) as NSMutableDictionary
                
                let uid = message.valueForKeyPath("sender.auth.uid") as NSString
                let messageText = message.valueForKeyPath("message.message") as NSString
                let messageImageString =  message.valueForKeyPath("message.image") as? NSString
                let senderEmailText = message.valueForKeyPath("sender.password.email") as? NSString
                let senderPositionArray: NSArray = message.valueForKey("position") as NSArray
                let sentAt: AnyObject  =  message.valueForKey("createdAt")!
                let senderID = message.valueForKeyPath("sender.auth.uid") as NSString
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
                var textMessageView = UITextView()
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
                    textMessageView = UITextView(frame: CGRectMake(sideInset, cellHeight, maxMessageViewWidth, messageViewHeight))
                    textMessageView.text = messageText
                    messageViewY = textMessageView.bounds.origin.y
                }else{
                    textMessageView = UITextView(frame: CGRectMake(sideInset, cellHeight, 0, 0))
                    textMessageView.text = messageText
                    textMessageView.sizeToFit()
                }
                
                textMessageView.layer.cornerRadius = textMessageView.bounds.height / 8  //20% of width
                
                
                self.messageView.insertSubview(textMessageView, atIndex: keyIndex)
                
                
    
                //avatarImageview
                
                let avatarImageWidth: CGFloat = 30
                let avatarImageHeight: CGFloat = 30
                let gabMessageViewToAvatar: CGFloat = 5
                    avatarImageView = UIImageView(frame: CGRectMake(sideInset, cellHeight, avatarImageWidth, avatarImageHeight))
                
                if(avatarImageString != "" && avatarImageString != " "){
    
                    let avatarData = NSData(base64EncodedString: avatarImageString, options: .allZeros)
                    avatarImageView.image = UIImage(data: avatarData!)
            
                }else{
                    
//                    let emailInitial = senderEmailText?.substringWithRange(NSMakeRange(0, 2))
//                    let attributes = NSAttributedString(string: emailInitial!)
//                    println(emailInitial)
                    let emailInitial = "rr"
                    
                    UIGraphicsBeginImageContext(avatarImageView.frame.size)
                   // let attibutes = NSDictionary()
                    //let att1 = NSAttributedString(string: emailInitial)
                    emailInitial.drawAtPoint(CGPointMake(10, 10), withAttributes: nil )
                    let retImage = UIGraphicsGetImageFromCurrentImageContext()
                   UIGraphicsEndImageContext()
                   avatarImageView.image = retImage
                    
                    
//                    let textColor = UIColor.redColor()
//                    let textFontAttributes = [NSForegroundColorAttributeName: textColor]
//                    
//                    emailInitial.drawInRect(avatarImageView.frame, withAttributes: textFontAttributes)
//                    
                    
                }
                
                
                avatarImageView.layer.cornerRadius = avatarImageWidth/2
                avatarImageView.layer.borderWidth = 0.5
                avatarImageView.layer.backgroundColor = UIColor.lightGrayColor().CGColor
             
                self.messageView.insertSubview(avatarImageView, atIndex: keyIndex)
                //self.messageView.addSubview(avatarImageView)
              
                
                
                avatarImageView.transform.tx = textMessageView.frame.width + gabMessageViewToAvatar
                avatarImageView.transform.ty = textMessageView.frame.height - avatarImageHeight
                
                
                // lables
                let verticalSpacing : CGFloat = 5
                let labelPlacing = textMessageView.frame.height + verticalSpacing
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
//                self.messageView.addSubview(senderEmailButton)
//                self.messageView.addSubview(sentAtLabel)
//                self.messageView.addSubview(senderPositionButton)
                
                self.messageView.insertSubview(senderEmailButton, atIndex: keyIndex)
                self.messageView.insertSubview(sentAtLabel, atIndex: keyIndex)
                self.messageView.insertSubview(senderPositionButton, atIndex: keyIndex)
                
                
                
                
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
                    textMessageView.transform.ty = imageMessageHeight
                    avatarImageView.transform.ty = imageMessageHeight
                    senderEmailButton.transform.ty = imageMessageHeight
                    senderPositionButton.transform.ty = imageMessageHeight
            
                    
                    //self.messageView.addSubview(imageMessageView)
                    self.messageView.insertSubview(imageMessageView, atIndex: keyIndex)
                    
                }
                
                
                // Tarnsformation based on sender
                if(self.user?.uid == message.valueForKeyPath("sender.auth.uid") as? NSString){
                    
                    textMessageView.transform.tx = self.view.bounds.width - textMessageView.bounds.width - 2 * sideInset
                    imageMessageView.transform.tx = self.view.bounds.width - imageMessageView.bounds.width - 2 * sideInset
                    avatarImageView.transform.tx = self.view.bounds.width - textMessageView.bounds.width - avatarImageView.bounds.width - gabMessageViewToAvatar - 2 * sideInset
                    senderEmailButton.transform.tx = self.view.bounds.width - 2 * senderEmailButton.frame.width
                    senderPositionButton.transform.tx = self.view.bounds.width - senderPositionButton.frame.origin.x + senderPositionButton.frame.width - 2 * sideInset
                    
                    // transform with the messageView
                    sentAtLabel.transform.tx = self.view.bounds.width - textMessageView.bounds.width - 2 * sideInset - (sentAtLabel.frame.width - textMessageView.bounds.width)
                   // println(self.view.bounds.width)

                    textMessageView.backgroundColor = UIColor.greenColor()
                    
                    
                    
                }else{
                    
                    textMessageView.backgroundColor = UIColor.lightGrayColor()
                    
                }
                
                //add a dividing line
//                let line = UILabel(frame: CGRectMake(self.view.bounds.width * 0.25, cellHeight - bottomInset, self.view.bounds.width/2, 1))
//                line.backgroundColor = UIColor.lightGrayColor()
//                line.layer.cornerRadius = line.bounds.height/2
//                self.view.addSubview(line)
              
                // add cell height
                cellHeight = cellHeight + imageMessageHeight +  senderEmailButton.bounds.height + verticalSpacing +  textMessageView.bounds.height + bottomInset * 2
                //println(cellHeight)
          
                
                
                
            }
            ////////////////////////////END FOR LOOP//////////////////////////////////////////
            
            
            
            self.scrollerHeight = cellHeight + self.senderView.frame.height
    
            self.scroller.contentSize = CGSizeMake(self.view.bounds.width, self.scrollerHeight)
            self.scroller.scrollsToTop = true
            //scroll bottom
            self.scroller.setContentOffset(CGPointMake(0, self.scroller.contentSize.height - self.scroller.bounds.size.height), animated: false)

            println(self.messageView.subviews.count)
        })
        
        
        
    }
    
    
}