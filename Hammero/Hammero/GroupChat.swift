//
//  GroupChat.swift
//  Hammero
//
//  Created by fasil fikreab on 12/7/14.
//  Copyright (c) 2014 fasil fikreab. All rights reserved
//


import UIKit


class GroupChat: UIViewController, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
    
{
    
    var user:FAuthData? = nil
    var club: AnyObject = [:]
    var ref = Firebase(url: "https://peopler.firebaseio.com")
    var currentRef = Firebase()
    var clubID: String = String()
    
    var currentUserID = String()
    var scrollerHeight: CGFloat = 0.0
    
    var messages = Messages()
    
    var textViewDidChangeCounter = 0
    
    var senderView = UIView()
    var scroller = UIScrollView()
    //var messageView =  UIView()
    
    var attachmentButton = UIButton()
    var sendButton = UIButton()
    var messageBox = UITextView()
    
    var keyboardHeight: CGFloat = 0
    
    // constants
    //postisions in senderView
    let inset: CGFloat = 4.0
    let spaceToBottom: CGFloat = 40
    let senderViewHeight: CGFloat = 60
    var lineLimit: CGFloat = 6
    
    //message limit from firbae
    var messageLimitedTo: UInt = 20
    
    var textMessage: String = ""
    
    var imagePickerController = UIImagePickerController()
    
    var pickerImage = UIImage()
    var pickerImageString : String = ""
    var pickerImageHeight: CGFloat = 0
    
    
    
    
    // MARK: - View Controller Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let instance = MyClubsSingleton.sharedInstance
        self.club = instance.getClub()
        self.title = self.club.valueForKey("name") as? String
        self.checkAuth()
        
        self.clubID = self.club.valueForKey("clubID") as String
        self.currentRef = ref.childByAppendingPath("/messages/" + clubID + "/all")
        // currentRef = groupRef
        self.setupFirebase("group")
        
        
        self.messageBox.delegate = self
        self.imagePickerController.delegate = self
        
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        ref.removeAllObservers()
    }
    
    override func loadView() {
        // loadView should never call super
        
        self.view = UIView(frame: UIScreen.mainScreen().bounds)
        self.scroller = UIScrollView(frame: self.view.frame)
        //self.scroller.addSubview(messageView)
        
        self.view.addSubview(scroller)
        
        self.scroller.backgroundColor = UIColor.whiteColor()
        
        
        self.setupSenderView()
        
    }
    
    
    // MARK: - Attachement, Camera, PhotoLibs
    
    func getAttachment(sender: UIButton){
        
        
        let actionSheet = UIActionSheet(title: "Choose attachement", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Choose from camera roll", "take photo", "attach PDF")
        actionSheet.showInView(senderView)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if(buttonIndex == 1){
            self.chooseFromCameraRoll()
        }else if(buttonIndex == 2){
            self.takePhoto()
        }else if(buttonIndex == 3){
            self.attachPDF()
        }
    }
    
    func chooseFromCameraRoll(){
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)){
            
            self.imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePickerController, animated: true, completion: {
                
            })
            
        }
    }
    
    func takePhoto(){
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            
            self.imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(imagePickerController, animated: true, completion: {
                
                
            })
            
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let infoImage: UIImage =  info[UIImagePickerControllerOriginalImage] as UIImage
        
        
        self.pickerImage = infoImage
        
        let imageData = UIImagePNGRepresentation(infoImage) //returns NSData
        let imageDecoded = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
        self.pickerImageString = imageDecoded
        
        
        self.imagePickerController.dismissViewControllerAnimated(true, completion: nil)
        messageBox.becomeFirstResponder()
        
    }
    
    
    
    func attachPDF(){
        
    }
    
    
    //MARK: - TextView Deligates
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        textView.text = ""
        textView.textColor = UIColor.blackColor()
        
        if(pickerImageString != ""){
            self.pickerImageHeight = 50
            textView.bounds.size.height += 50
            senderView.bounds.size.height += 50  //room for image height
            
            
            let imageInText = NSTextAttachment()
            imageInText.bounds = CGRectMake(0, 0, 50 , 50)
            imageInText.image = self.pickerImage
            let attributedString = NSAttributedString(attachment: imageInText)
            messageBox.attributedText = attributedString
            
            
            
            
        }
        
        let keyboardNotification = NSNotificationCenter.defaultCenter()
        keyboardNotification.addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        keyboardNotification.addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        
        
    }
    
    
    
    func textViewDidChange(textView: UITextView) {
        
        
        var currentHeight = floor(textView.contentSize.height / textView.font.lineHeight)
        var heightWithInsets : CGFloat = textView.contentSize.height
        
        let newLineToggler = Int(currentHeight % 2) //detects changes from odd to even number
        
        
        self.textMessage = textView.text //save text
        
        if(currentHeight <= lineLimit){
            
            
            textView.bounds.size.height = floor(textView.contentSize.height)
            
            
            
            if(newLineToggler == 0){
                
                if(self.textViewDidChangeCounter > 0){
                    
                    textView.frame.origin.y = self.view.frame.height - self.keyboardHeight - heightWithInsets - spaceToBottom/4
                    senderView.bounds.size.height = senderViewHeight  + heightWithInsets
                    senderView.frame.origin.y =  textView.frame.origin.y - spaceToBottom
                }
                // set the couter back to zero
                self.textViewDidChangeCounter = 0
                
                if(currentHeight <= 2){
                    
                    // sets the view back to its original position
                    self.senderView.bounds.size.height = senderViewHeight
                    self.senderView.frame.origin.y = self.view.frame.height - self.keyboardHeight - senderViewHeight
                    self.messageBox.frame.origin.y = self.view.frame.height - self.keyboardHeight - spaceToBottom
                    
                }
                
                
                
            }
            
            if(newLineToggler == 1 ){
                self.textViewDidChangeCounter++
                let flag = 1 - self.textViewDidChangeCounter
                if(flag == 0){
                    textView.frame.origin.y = self.view.frame.height - self.keyboardHeight - heightWithInsets - spaceToBottom/4
                    senderView.bounds.size.height =  senderViewHeight + heightWithInsets
                    senderView.frame.origin.y =  textView.frame.origin.y - spaceToBottom
                }
                
                
            }
            
        }
        
    }
    
    
    func keyboardWasShown(note: NSNotification){
        
        
        let info = note.userInfo!
        let rect = info[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue()
        let keyboardHeight = rect.size.height
        self.keyboardHeight = keyboardHeight
        
        self.senderView.frame.origin.y = self.view.bounds.height - senderView.frame.height -  keyboardHeight
        self.attachmentButton.frame.origin.y =  self.view.bounds.height - attachmentButton.frame.height -  keyboardHeight - 10
        self.messageBox.frame.origin.y = self.view.bounds.height - messageBox.frame.height -  keyboardHeight - 10
        self.sendButton.frame.origin.y = self.view.bounds.height - sendButton.frame.height -  keyboardHeight - 10
        
        self.scroller.setContentOffset(CGPointMake(0, self.scroller.contentSize.height - keyboardHeight), animated: true)
        
        
        
    }
    
    func keyboardWillBeHidden(note: NSNotification){
        
        self.scroller.setContentOffset(CGPointMake(0, self.scroller.contentSize.height - self.scroller.bounds.size.height), animated: true)
        self.senderView.frame.origin.y = self.view.bounds.height - senderViewHeight
        self.attachmentButton.frame.origin.y = self.view.bounds.height - spaceToBottom - 2
        self.messageBox.frame.origin.y = self.view.bounds.height - spaceToBottom
        self.sendButton.frame.origin.y = self.view.bounds.height - spaceToBottom
        
        self.keyboardHeight = 0
        self.scroller.contentSize = CGSizeMake(self.view.bounds.width, self.scrollerHeight + self.keyboardHeight)
        // self.scroller.transform.ty = keyboardHeight
        
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
        self.scroller.endEditing(true)
        
    }
    
    
    
    
    //MARK: - Sender view
    
    func  setupSenderView(){
        
        
        senderView.frame.origin = CGPointMake(self.view.frame.origin.x, self.view.frame.size.height - senderViewHeight)
        senderView.frame.size = CGSizeMake(self.view.bounds.width, senderViewHeight)
        senderView.backgroundColor = UIColor.lightGrayColor()
        
        let myToolBarPosition = CGPointMake(self.view.frame.origin.x, self.view.frame.size.height - spaceToBottom)
        
        
        
        attachmentButton = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
        // attachmentButton.center  = myToolBarPosition
        attachmentButton.frame.origin.x = myToolBarPosition.x
        attachmentButton.frame.origin.y = myToolBarPosition.y
        attachmentButton.transform.ty = inset
        attachmentButton.transform.tx = inset
        // attachmentButton.setImage(UIImage(named: "camera-25"), forState: UIControlState.Normal)
        //attachmentButton.sizeToFit()
        attachmentButton.addTarget(self, action: "getAttachment:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        sendButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        sendButton.frame.origin.x = myToolBarPosition.x
        sendButton.frame.origin.y = myToolBarPosition.y
        sendButton.setTitle("Send", forState: UIControlState.Normal)
        sendButton.sizeToFit()
        sendButton.transform.tx = self.view.frame.width - sendButton.frame.width - 2 * inset
        sendButton.addTarget(self, action: "sendMessage:", forControlEvents: UIControlEvents.TouchUpInside)
        
        messageBox.delegate = self
        
        let inputTextSize = "any text".sizeWithAttributes(nil).height * 2
        let messageBoxLength = self.view.frame.width - attachmentButton.frame.width - sendButton.frame.width - 5 * inset
        let messageBoxHeight = inputTextSize
        
        
        messageBox.frame = CGRectMake(myToolBarPosition.x, myToolBarPosition.y, messageBoxLength, messageBoxHeight)
        messageBox.backgroundColor = UIColor.whiteColor()
        //        messageBox.layer.borderColor = UIColor.redColor().CGColor
        //        messageBox.layer.borderWidth = 1.0
        messageBox.layer.cornerRadius = 5
        
        
        messageBox.transform.tx = attachmentButton.frame.width + 2 * inset
        messageBox.text = "Message"
        messageBox.textColor = UIColor.lightGrayColor() // get ride of these two lines in textfielddidStartEditng delegate
        
        
        
        self.view.addSubview(senderView)
        
        self.view.addSubview(attachmentButton)
        self.view.addSubview(messageBox)
        self.view.addSubview(sendButton)
        
        
    }
    
    
    // Mark :- Personal Chat
   
    func backToGroupChat(sender: UIBarButtonItem){
  
        //let clubID = self.club.valueForKey("clubID") as String
        self.currentRef = ref.childByAppendingPath("/messages/" + clubID + "/all")
        
        self.navigationItem.rightBarButtonItem = nil
        self.title = self.club.valueForKey("name") as? String
        self.setupFirebase("group")
        
    }
    
    func personalChat(sender: UIButton){
    
        let msges: NSDictionary = messages.getMessages()
        let keys: NSArray = messages.getIndexArray()
        let messageID: String = keys[sender.tag] as String
        let message: NSDictionary = msges.valueForKeyPath(messageID) as NSDictionary
        
       let senderID = message.valueForKeyPath("sender.auth.uid")! as String
        
        var person = senderID
        var currentUser = self.user?.uid
        var refName = String()
        if (person < currentUser){
            refName = person + "," + currentUser!
        }else{
            //console.log("else is called")
            
            refName = currentUser! + "," + person;
            //console.log(refName)
            // 177,178
        }
  
        //let clubID = self.club.valueForKey("clubID") as String
        var messagePersonRef = ref.childByAppendingPath( "/messages/" + clubID + "/person/" + refName)
        self.currentRef = messagePersonRef
      
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "backToGroupChat:")
        self.navigationItem.rightBarButtonItem = rightButton 
        self.title = sender.titleLabel?.text
        sender.enabled = false
        self.setupFirebase("personal")
   
        sender.setTitleColor(UIColor.redColor(), forState: UIControlState.Disabled)
        
        //message alerts
        
//        let receiver = NSMutableDictionary()
//            receiver.setValue(person, forKey: "person") //["person": person, "futureLocation": "fromIphone"]
//            receiver.setValue("from iPhone", forKey: "futureLocation")
//        let sender    =  NSMutableDictionary()// ["person": currentUser, "futureLocation": false]
//            sender.setValue(currentUser, forKey: "person")
//            sender.setValue(false, forKey: "futureLocation")
//        let update = NSMutableDictionary()
//            update.setValue(receiver, forKey: "receiver")
//            update.setValue(sender, forKey: "sender")
        
        
        
        //println(update)
//        messagePersonRef.update({
//        receiver: ["person": person, "futureLocation": "fromIphone"], "sender": {"person": currentUser, "futureLocation": false}
//        })
//        
        //clubRef.child("members/" + currentUser.uid + "/messagebox/" + person).remove()//(messageboxItem)

        
    }
    
    
     // Mark: - Send Messages
    
    func sendMessage(sender: UIButton){
        
        
        let messageData = ["message": messageBox.text, "image": pickerImageString]
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
        
        
        
        //let clubID = self.club.valueForKey("clubID") as String
        
       self.currentRef.childByAutoId().setValue(value, withCompletionBlock: {
            error, firbase in
            //println(error)
            //println(firbase)
        })
        
        
        // reset some views
        self.messageBox.text = nil
        let inputTextSize = "any text".sizeWithAttributes(nil).height * 2
        self.messageBox.frame.size.height = inputTextSize
        self.messageBox.frame.origin.y = self.view.frame.height - self.keyboardHeight - spaceToBottom
        self.senderView.bounds.size.height = senderViewHeight
        self.senderView.frame.origin.y = self.view.frame.height - self.keyboardHeight - senderViewHeight
        
        
        
        self.pickerImage = UIImage()
        self.pickerImageString = ""
        
        
    }
    
    
    func checkAuth(){
        
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated with Firebase
                self.user = authData
                
            } else {
                self.performSegueWithIdentifier("checkAuth", sender: self)
            }
        })
    }
    
    
    
    
    // MARK: - Setup Firebase to Recieve Messages
    
    func  setupFirebase(type: String){
        println(type)
        self.currentRef.queryLimitedToLast(messageLimitedTo).observeEventType(.Value, withBlock: {
            dataSnapshot in

            if(dataSnapshot.value as NSObject == NSNull()){
                
                
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
                messagesDictionary.removeObjectForKey("sender")
                messagesDictionary.removeObjectForKey("receiver") // these are metadata, not keys
            
            // Dictionary does not have a guarenteed order. Arrays do. So chane to arrary and sort here
            var unsortedMessages = messagesDictionary.allKeys
        
            
            let sortedMessageKeys: NSArray =  unsortedMessages.sorted({ (s1, s2) -> Bool in
                s2 as String > s1 as String
            })
            
            self.messages.setMessages(messagesDictionary, indexArray: sortedMessageKeys)
            

            
            if(self.scroller.subviews.count > 0){
                
                for aView in self.scroller.subviews{
                    
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
                
                // messageView. all View positions based on textmessageView
                if( messageTextStringLength > maxMessageViewWidth){
                    textMessageView = UITextView(frame: CGRectMake(sideInset, cellHeight, maxMessageViewWidth, messageViewHeight))
                    textMessageView.text = messageText
                    messageViewY = textMessageView.bounds.origin.y
                }else{
                    textMessageView = UITextView(frame: CGRectMake(sideInset, cellHeight, 0, 0))
                    textMessageView.text = messageText
                    textMessageView.sizeToFit()
                }
                
                if(textMessageView.bounds.width < textMessageView.bounds.height){
                    textMessageView.layer.cornerRadius = textMessageView.bounds.width / 8  //20% of width
                    
                }else{
                    textMessageView.layer.cornerRadius = textMessageView.bounds.height / 8  //20% of width
                    
                }
                
                
                
                
                
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
                
                //self.scroller.insertSubview(avatarImageView, atIndex: keyIndex)
                
                
                
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
                senderEmailButton.addTarget(self, action: "personalChat:", forControlEvents: UIControlEvents.TouchUpInside)
                senderEmailButton.tag = keyIndex
               
        
        
                
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
                self.scroller.addSubview(avatarImageView)
                self.scroller.addSubview(textMessageView)
                self.scroller.addSubview(senderEmailButton)
                self.scroller.addSubview(sentAtLabel)
                self.scroller.addSubview(senderPositionButton)
                
                //                self.messageView.insertSubview(senderEmailButton, atIndex: keyIndex)
                //                self.messageView.insertSubview(sentAtLabel, atIndex: keyIndex)
                //                self.messageView.insertSubview(senderPositionButton, atIndex: keyIndex)
                
                
                
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
                    
                    
                    self.scroller.addSubview(imageMessageView)
                   // self.scroller.insertSubview(imageMessageView, atIndex: keyIndex)
                    
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
                    
                    if(type == "personal"){
                        textMessageView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 0.5)
                        
                    }else{
                         textMessageView.backgroundColor = UIColor.greenColor()
                    }
                   
                    
                    
                    
                }else{
                    if(type == "personal"){
                    textMessageView.backgroundColor = UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 0.5)
                    }else{
                        textMessageView.backgroundColor = UIColor.lightGrayColor()
 
                    }
                }
                
                cellHeight = cellHeight + imageMessageHeight +  senderEmailButton.bounds.height + verticalSpacing +  textMessageView.bounds.height + bottomInset * 2
                
                
                
                
                
                
                
                
            }
            ////////////////////////////END FOR LOOP//////////////////////////////////////////
            
            
            
            self.scrollerHeight = cellHeight + self.senderView.frame.height
            
            self.scroller.contentSize = CGSizeMake(self.view.bounds.width, self.scrollerHeight + self.keyboardHeight)
            self.scroller.scrollsToTop = true
            //scroll bottom
            self.scroller.setContentOffset(CGPointMake(0, self.scroller.contentSize.height - self.scroller.bounds.size.height), animated: false)
        })
        
        
        
    }
    
    
    
    
}