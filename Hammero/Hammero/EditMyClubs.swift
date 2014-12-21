//
//  EditMyClubs.swift
//  Hammero
//
//  Created by fasil fikreab on 12/4/14.
//  Copyright (c) 2014 fasil fikreab. All rights reserved.
//

import UIKit

class EditMyClubs: UIViewController, UITextFieldDelegate, UIAlertViewDelegate,UIImagePickerControllerDelegate,UIPopoverControllerDelegate, UINavigationControllerDelegate {

    var ref = Firebase(url: "https://peopler.firebaseio.com")
    
    var user: FAuthData? = nil
    var club: AnyObject? = nil
    var imageString : String = ""

    
    var picker:UIImagePickerController?=UIImagePickerController()
    var popover:UIPopoverController?=nil

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var clubNameField: UITextField!
    @IBOutlet weak var clubDescriptionField: UITextField!
    
    
    
    @IBAction func changePicture(sender: AnyObject) {
        
        println("ok I will change the picutre")
        var alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openCamera()
                
        }
        var gallaryAction = UIAlertAction(title: "Gallary", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openGallary()
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
            {
                UIAlertAction in
                
        }
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the actionsheet
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            popover=UIPopoverController(contentViewController: alert)
            popover?.presentPopoverFromBarButtonItem(self.navigationItem.backBarButtonItem!, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        println(image)
        
        
        let imageData = UIImagePNGRepresentation(image) //returns NSData
        let imageDecoded = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
        self.imageString = imageDecoded
        self.avatarImage.image = image
        self.updateFirebase()
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!)
    {
        println("picker cancel.")
    }
    
    
    @IBAction func submitChanges(sender: AnyObject) {
        self.checkAuthAndUpdate()
        
    }

    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            openGallary()
        }
    }
    
    func openGallary()
    {
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            popover=UIPopoverController(contentViewController: picker!)
             popover?.presentPopoverFromBarButtonItem(self.navigationItem.backBarButtonItem!, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func checkAuthAndUpdate(){
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil && authData.uid == self.club?.valueForKey("founders_id") as String {
                // user authenticated with Firebase and she is the founder
                self.user = authData
                self.updateFirebase()
               
               
                
            } else {
                self.performSegueWithIdentifier("checkAuth", sender: self)
            }
        })
    }
    
    
    
    func  updateFirebase(){
        let clubID = club?.valueForKey("clubID") as String
        let values = ["name": self.clubNameField.text, "description": self.clubDescriptionField.text, "avatar":self.imageString]
        ref.childByAppendingPath("clubs/" + clubID).updateChildValues(values, withCompletionBlock: { (error, snap) -> Void in
            if(error == nil){
                snap.observeEventType(.Value, withBlock: {
                    dataSnapshot in
                    let instance =  MyClubsSingleton.sharedInstance
                    instance.setClubModification(true)
                    
                    let temp: AnyObject! =  dataSnapshot.value
                    temp.addEntriesFromDictionary(["clubID": dataSnapshot.key])
                    instance.setClub(temp, atRow: instance.getRow())
                    
                     self.navigationController?.popViewControllerAnimated(true)
                    println("no errors")
                    
                })

              
            }
        })
    }
    
        var detailItem: AnyObject? {
            didSet {
                // Update the view.
                self.configureView()
                
            }
        }

        
        func configureView() {
         
            
            let inst =  MyClubsSingleton.sharedInstance
            let club: AnyObject = inst.getClub()
            
            self.club = club
            self.clubNameField.clearsOnBeginEditing = false
          
            self.clubDescriptionField.clearsOnBeginEditing = false
            self.clubNameField.text = club.valueForKey("name") as String
            self.clubDescriptionField.text = club.valueForKey("description") as String
            
            let imageString = club.valueForKey("avatar") as? String
            let imageData = NSData(base64EncodedString: imageString!, options: .allZeros)
            
            self.avatarImage.image = UIImage(data: imageData!)

            
          }
   
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view, typically from a nib.
        
            self.configureView()
            self.picker?.delegate = self
            self.picker?.allowsEditing = true
            
           // println(club)

            
        }
    
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    
    
    // Mark:- Textfield
    func textFieldShouldReturn( textField: UITextField) -> Bool{
        self.checkAuthAndUpdate()
        textField.resignFirstResponder()
        return false
    }

    
    }






