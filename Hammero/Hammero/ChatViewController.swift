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
        super.viewWillAppear(animated: false)
        
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
            
            println(unsortedMessages.count);print("....")
            println(sortedMessageKeys.count)
            
            for keyIndex in 0...sortedMessageKeys.count - 1 {
                
                let message: AnyObject = messagesDictionary.valueForKey(sortedMessageKeys[keyIndex] as String)!
                self.recievedMessages[keyIndex] = message
                
                self.table?.reloadData()
                
                
                // let uid = message.valueForKeyPath("sender.auth.uid") as NSString
                
                //                self.ref.childByAppendingPath("/users/" + uid).observeEventType(.Value, withBlock: {
                //                    dataSnapshot in
                //                    let auth = dataSnapshot.value as NSDictionary
                
                
                //
                //                    temp[0] = message.valueForKeyPath("message.message")!
                //                    temp[1] =  message.valueForKeyPath("message.image")!
                //                    temp[2] = message.valueForKeyPath("sender.password.email")!
                //                    temp[3] = message.valueForKey("position")!
                //                    temp[4] =  message.valueForKey("createdAt")!
                //                    temp[5] =  auth.valueForKey("avatar")!
                //                    temp[6] = message.valueForKeyPath("sender.auth.uid")!
                
                
                
                //                    self.recievedMessages[keyIndex] = message
                //                    self.table?.reloadData()
                //
                //                    //self.table.reloadData()
                //
                //                    let x = sortedMessageKeys.count
                //                    let y = self.recievedMessages.count
                //
                //
                //                    if(x == y){
                //
                //                        // collectionview done reloading data, send noticicatin
                //                        println("ready to send notification")
                ////                        let doneReloading = NSNotificationCenter.defaultCenter()
                ////                        doneReloading.postNotificationName("doneReloading", object: self, userInfo: nil)
                //                        println(self.recievedMessages.count)
                //                         self.table?.reloadData()
                //                    }
                //
                //
                //                })
                // println(self.recievedMessages.count)
                
            }
            
            
        })
        
        
        
    }
    
    
    
    
    
    
    
    
    //    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    //
    //        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
    //
    //        println("func 2 is run")
    
    //        let offsetWidth = self.view.bounds.width * 0.98 // 30 percent from minX of View
    //
    //
    //        let gap: CGFloat = 10
    //
    //        var messageView = UITextView()
    //        var displayNameView = UITextView()
    //
    //        if( messageText.sizeWithAttributes(nil).width > self.view.bounds.width * 0.80){
    //
    //            var x = messageText.sizeWithAttributes(nil).width
    //            var y = self.view.bounds.width * 0.8
    //            var z = x/y // this is the number of lines required
    //            var padding: CGFloat = 12
    //            let textBoxHeight = (ceil(z) + 1) * messageText.sizeWithAttributes(nil).height + padding
    //
    //            messageView = UITextView(frame: CGRectMake(0    , 0, self.view.bounds.width * 0.80, textBoxHeight))
    //            messageView.text = messageText
    //
    //
    //        }else{
    //            messageView = UITextView(frame: CGRectMake(0    , 0, 0, 0))
    //            messageView.text = messageText
    //            messageView.sizeToFit()
    //
    //
    //        }
    //
    //
    //
    //        messageView.layer.cornerRadius = messageView.bounds.height / 8  //20% of width
    //
    //        cell.addSubview(messageView)
    
    
    
    
    // return cell
    //}
    
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        //println(self.recievedMessages.count)
        return self.recievedMessages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell", forIndexPath: indexPath) as ChatCell
        
        let message = self.recievedMessages[indexPath.row] as NSDictionary
        let uid = message.valueForKeyPath("sender.auth.uid") as String
       // var messageText, messageImageString, senderEmailText, postionText, sentAtText, avatarImageString, senderIDSText : String
        
        self.ref.childByAppendingPath("/users/" + uid).observeEventType(.Value, withBlock: {
            dataSnapshot in
            let auth = dataSnapshot.value as NSDictionary
            
           
            
            let messageText = message.valueForKeyPath("message.message") as? String
            let messageImageString =  message.valueForKeyPath("message.image") as? String
            let senderEmailText = message.valueForKeyPath("sender.password.email") as? String
            let postionText = message.valueForKey("position") as? String
            let sentAtText  =  message.valueForKey("createdAt") as? String
            let avatarImageString  =  auth.valueForKey("avatar") as? String
            let senderIDSText = message.valueForKeyPath("sender.auth.uid") as? String
            
     
            
            cell.textMessageView.text = messageText
            cell.imageMessageView.image = self.changeImageStringToImage(messageImageString!, withType: "message")
            cell.senderEmailLabel.text = senderEmailText
            cell.sentTimeLabel.text = sentAtText
            cell.avatarImageView.image = self.changeImageStringToImage(avatarImageString!,withType: "avatar")
            cell.senderPositionLabel.text = postionText
            
           

            
        })
        
        
        
        
        return cell
        
    }
    
    
    func changeImageStringToImage(imageString: String, withType: String) -> UIImage {
        if(imageString != ""){
            let imageData = NSData(base64EncodedString: imageString, options: .allZeros)
            return UIImage(data: imageData!)!
        }else {
            if(withType == "message"){
                return UIImage(named: "icon-40")!

            }else{
              
                return UIImage(named: "avatar-default")!
            }
            
        }
        
    
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
