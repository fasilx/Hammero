//
//  ChatViewController.swift
//  Hammero
//
//  Created by fasil fikreab on 1/3/15.
//  Copyright (c) 2015 fasil fikreab. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet var table: UITableView!
    
    //@IBOutlet var tableView: UITableView!
    //@IBOutlet weak var tableView: UITableView!
    
    
    var user:FAuthData? = nil
    var club: AnyObject = [:]
    var ref = Firebase(url: "https://peopler.firebaseio.com")
    var currentSectionHeight: CGFloat = 0
    
    
    var recievedMessages: NSMutableArray =  []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let instance = MyClubsSingleton.sharedInstance
        self.club = instance.getClub()
        self.checkAuth()
        
        self.table.separatorColor = UIColor.clearColor()
        
        
        //scrollBottom()
        //(CGPointMake(0, CGFloat.max))
        
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        // scroll to bottom
    
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

            for keyIndex in 0...sortedMessageKeys.count - 1 {
                
                let message: AnyObject = messagesDictionary.valueForKey(sortedMessageKeys[keyIndex] as String)!
                self.recievedMessages[keyIndex] = message
                
                self.table?.reloadData()

            }
        })
    }
    
   

    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return self.recievedMessages.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        cell = tableView.dequeueReusableCellWithIdentifier("ChatCell", forIndexPath: indexPath) as UITableViewCell
        
        let cellHeight = cell.frame.height * CGFloat(indexPath.row)
        let redBox = UIView(frame: CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + cellHeight , 100, 100))
        let blueBox = UIView(frame: CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + cellHeight, 120, 120))
        let blackBox = UIView(frame: CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + cellHeight, 140, 140))
        
        redBox.backgroundColor  = UIColor.redColor()
        blueBox.backgroundColor = UIColor.blueColor()
        blackBox.backgroundColor  = UIColor.blackColor()
        
        println(indexPath.row)
         self.view.addSubview(blackBox)
         self.view.addSubview(blueBox)
        self.view.addSubview(redBox)
       
       
        
//        let message = self.recievedMessages[indexPath.row] as NSDictionary
//        
//        let messageText = message.valueForKeyPath("message.message") as String
//        let messageImageString =  message.valueForKeyPath("message.image") as? String
//        let senderEmailText = message.valueForKeyPath("sender.password.email") as? String
//        let postionText = message.valueForKey("position") as? String
//        let sentAtText  =  message.valueForKey("createdAt") as? String
//        let senderID = message.valueForKeyPath("sender.auth.uid") as String
//        
//        
//
//        let inset: CGFloat = 10
//        let contentViewX = self.view.bounds.origin.x + inset
//        let contentViewY = self.view.bounds.origin.y + inset
//        
//        print(self.view.bounds)
//        println(self.view.frame)
//        
//        // create and configure messageView
//        var messageView = UITextView()
//        messageView.frame.origin = CGPointMake(contentViewX, contentViewY)
//        
//       
//        
//        messageView.editable = false
//        
//        // declare avatar view
//        var avatarView = UIImageView()
//        
//        // calculate messageView's frame based on its text content
//        var textWidth = messageText.sizeWithAttributes(nil).width
//        var textViewWidthShoudBe = cell.contentView.bounds.width * 0.8
//        var numberOfLines = textWidth/textViewWidthShoudBe // this is the number of lines required
//        var textHeight = messageText.sizeWithAttributes(nil).height
//        var padding: CGFloat = 10
//        let textBoxHeight = (ceil(numberOfLines) + 1) * textHeight + padding
//        
//        if( textWidth > textViewWidthShoudBe){
//          
//            messageView.bounds.size  = CGSizeMake(textViewWidthShoudBe, textBoxHeight)
//            messageView.text = messageText
//            messageView.layer.cornerRadius = messageView.frame.height/8
//          
//        }else{
////            messageView.frame.size  = CGSizeZero // this must be set back to zero or it cause glich in view
//            messageView.text = messageText
//            messageView.sizeToFit()
//            messageView.layer.cornerRadius = messageView.frame.height/8
//        
//        }
//        
//        // get user avatar from firebase, and create and configure
//        self.ref.childByAppendingPath("/users/" + senderID).observeEventType(.Value, withBlock: {
//            dataSnapshot in
//            
//            let auth = dataSnapshot.value as NSDictionary
//            let avatarImageString  =  auth.valueForKey("avatar") as? String
//            
//            let avatarWidth: CGFloat = 30.0; let avatarHeight : CGFloat = 30.0; let flowGapMesageToAvatar: CGFloat = 5.0
//            
//            // avatar position is calculated based on message view
//            let avatarViewY = messageView.bounds.height - avatarHeight
//                avatarView = UIImageView(frame: CGRectMake(contentViewX, avatarViewY, avatarWidth, avatarHeight))
//                avatarView.layer.cornerRadius = avatarWidth/2
//                avatarView.transform.tx = messageView.bounds.width + flowGapMesageToAvatar
//                avatarView.transform.ty = inset
//                avatarView.layer.borderWidth = 0.5
//                avatarView.layer.borderColor = UIColor.lightGrayColor().CGColor
//
////            if(avatarImageString != "" && avatarImageString != " ")
////            {
////                avatarView.image = self.changeImageStringToImage(avatarImageString!)
////                
////            }else{
//                avatarView.image = UIImage(named: "avatar-default")
//            //}
//            
//            // content of avatar must be added inside this completion block, or it doesn't exist
//            cell.contentView.addSubview(avatarView)
//            
//        })
//        
//        // process messageImageView
//        var messageImageViewWidth: CGFloat = 0
//        var messageImageViewHeight: CGFloat = 0
//        var messageImageView = UIImageView()
//        
//        
//        if(messageImageString  != "" && messageImageString != " ")
//        {
//            var messageImageViewWidth: CGFloat = 100.0
//            var messageImageViewHeight: CGFloat = 100.0
//            messageImageView = UIImageView(frame: CGRectMake(contentViewX, contentViewX, messageImageViewWidth, messageImageViewHeight))
//            messageImageView.layer.cornerRadius = messageImageViewWidth/8
//            messageImageView.clipsToBounds = true
//            
//            messageImageView.image = self.changeImageStringToImage(messageImageString!)
//            //move messageView down for image
//            messageView.transform.ty = messageImageViewHeight
//        
//        }
////           else{
////            messageImageView = UIImageView(frame: CGRectZero)
////            
////            //messageImageView.image = nil
////            
////            //move messageView down for image
////
////            
////            
////        }
//        
//       // add messageViews to content view of cell
//        cell.addSubview(messageImageView)
//        cell.addSubview(messageView)
//        
//        
//       
//        // transform cell based on sender ID
//        if(senderID == self.user?.uid){
//            
////            let cellTransform = CGAffineTransformMake(-1, 0, 0, 1, 0, 0)
////            
////            let subviewsTransform = CGAffineTransformMake(-1, 0, 0, 1, 0, 0)
////            let messageViewTransformForImageView = CGAffineTransformMakeTranslation(0, messageImageViewHeight)
////            messageView.transform = subviewsTransform
////            avatarView.transform = subviewsTransform
////            messageImageView.transform = messageViewTransformForImageView
////            //messageView.transform.tx = messageImageViewHeight
////            println("message tarnaslate in senderId")
////            cell.transform = cellTransform
//
//
//            messageView.backgroundColor = UIColor.greenColor()
//            
//        }else{
//            
//            messageView.backgroundColor = UIColor.lightGrayColor()
//        }
//    
//        // tableviews rowHeight
//        tableView.rowHeight = messageView.frame.height + (2 * padding) + messageImageViewWidth
//     
        
        return cell
        
    }
    

 
   
    
    // Mark :- Helper Methods
    
    func changeImageStringToImage(imageString: String) -> UIImage {
       
            let imageData = NSData(base64EncodedString: imageString, options: .allZeros)
            return UIImage(data: imageData!)!
   
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
