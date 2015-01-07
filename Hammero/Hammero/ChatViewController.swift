//
//  ChatViewController.swift
//  Hammero
//
//  Created by fasil fikreab on 1/3/15.
//  Copyright (c) 2015 fasil fikreab. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
            
//            println(unsortedMessages.count);print("....")
//            println(sortedMessageKeys.count)
            
            for keyIndex in 0...sortedMessageKeys.count - 1 {
                
                let message: AnyObject = messagesDictionary.valueForKey(sortedMessageKeys[keyIndex] as String)!
                self.recievedMessages[keyIndex] = message
                
                self.table?.reloadData()

                
            }
            
            
        })
        
        
        
    }
    

    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        //println(self.recievedMessages.count)
        return self.recievedMessages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell", forIndexPath: indexPath) as UITableViewCell
        
        let message = self.recievedMessages[indexPath.row] as NSDictionary
        let uid = message.valueForKeyPath("sender.auth.uid") as String
        
        
        let messageText = message.valueForKeyPath("message.message") as String
        let messageImageString =  message.valueForKeyPath("message.image") as? String
        let senderEmailText = message.valueForKeyPath("sender.password.email") as? String
        let postionText = message.valueForKey("position") as? String
        let sentAtText  =  message.valueForKey("createdAt") as? String
        let senderID = message.valueForKeyPath("sender.auth.uid") as? String
        
        
//        //cell.textMessageView.text = messageText
//        println(cell.textMessageView.frame.size)
//        cell.textMessageView.sizeThatFits(CGSizeMake(40, 40))
//        println(cell.textMessageView.frame.size)
//        //cell.textMessageView.frame.size = cell.textMessageView.frame.size
        
//        cell.senderEmailLabel.text = senderEmailText
//        cell.sentTimeLabel.text = sentAtText
//        cell.senderPositionLabel.text = postionText
//        
       
        
        
    

        let contentViewX = cell.contentView.frame.origin.x
        let contentViewY = cell.contentView.frame.origin.y
        
        
        var messageView = UITextView()
        messageView.frame.origin = CGPointMake(contentViewX, contentViewY)
        messageView.editable = false
        
        var avatarView = UIImageView()
        
        
        var textWidth = messageText.sizeWithAttributes(nil).width
        var textViewWidthShoudBe = cell.contentView.bounds.width * 0.8
        var numberOfLines = textWidth/textViewWidthShoudBe // this is the number of lines required
        var textHeight = messageText.sizeWithAttributes(nil).height
        var padding: CGFloat = 10
        let textBoxHeight = (ceil(numberOfLines) + 1) * textHeight + padding
        
        if( textWidth > textViewWidthShoudBe){
          
            messageView.frame.size  = CGSizeMake(textViewWidthShoudBe, textBoxHeight)
            messageView.text = messageText
            messageView.layer.cornerRadius = messageView.frame.height/8
            //messageView.backgroundColor = UIColor.greenColor()
            
    
            
        }else{
           // messageView = UITextView(frame: CGRectMake(contentViewX, contentViewY, textWidth, textHeight))
            messageView.text = messageText
            messageView.sizeToFit()
            messageView.layer.cornerRadius = messageView.frame.height/8
            //messageView.backgroundColor = UIColor.blueColor()
            
 
        }
        
        self.ref.childByAppendingPath("/users/" + uid).observeEventType(.Value, withBlock: {
            dataSnapshot in
            
            let auth = dataSnapshot.value as NSDictionary
            let avatarImageString  =  auth.valueForKey("avatar") as? String
            
            let avatarWidth: CGFloat = 30.0; let avatarHeight : CGFloat = 30.0; let flowGapMesageToAvatar: CGFloat = 5.0
            
            let avatarViewY = messageView.frame.height - avatarHeight
                avatarView = UIImageView(frame: CGRectMake(contentViewX, avatarViewY, avatarWidth, avatarHeight))
                avatarView.layer.cornerRadius = avatarWidth/2
                avatarView.transform.tx = messageView.frame.width + flowGapMesageToAvatar
//                avatarView.transform.ty = messageView.frame.height
                avatarView.layer.borderWidth = 0.5
                avatarView.layer.borderColor = UIColor.lightGrayColor().CGColor
            
//            if(messageImageString != "" && messageImageString != " "){
//                cell.imageMessageView.image = self.changeImageStringToImage(messageImageString!, withType: "message")
//                
//            }else{
//                cell.imageMessageView.frame = CGRectZero
//            }
            
            if(avatarImageString != "" && avatarImageString != " ")
            {
                avatarView.image = self.changeImageStringToImage(avatarImageString!,withType: "avatar")
                
            }else{
                avatarView.image = UIImage(named: "avatar-default")
            }
            
            cell.contentView.addSubview(avatarView)
            
            
            
        })
        
       
        cell.addSubview(messageView)
        
        
        
        
        if(senderID == self.user?.uid){
            
            let cellTransform = CGAffineTransformMake(-1, 0, 0, 1, 0, 0)
            cell.transform = cellTransform
            
            let subviewsTransform = CGAffineTransformMake(-1, 0, 0, 1, 0, 0)
            messageView.transform = subviewsTransform
            avatarView.transform = subviewsTransform
//            cell.senderEmailLabel.transform = subviewsTransform
//            cell.sentTimeLabel.transform = subviewsTransform
//            cell.senderPositionLabel.transform = subviewsTransform
//        
            messageView.backgroundColor = UIColor.greenColor()
        
            
            
        }else{
            
            messageView.backgroundColor = UIColor.lightGrayColor()
        }
        
        return cell
        
    }
    
    
    func changeImageStringToImage(imageString: String, withType: String) -> UIImage {
       
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
