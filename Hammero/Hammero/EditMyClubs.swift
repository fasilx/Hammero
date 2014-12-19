//
//  EditMyClubs.swift
//  Hammero
//
//  Created by fasil fikreab on 12/4/14.
//  Copyright (c) 2014 fasil fikreab. All rights reserved.
//

import UIKit

class EditMyClubs: UIViewController {
    
   
  

    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var clubNameField: UITextField!
    @IBOutlet var clubDescriptionField: UITextField!
    
    
    
    @IBAction func changePicture(sender: AnyObject) {
        
        println("ok I will change the picutre")
        
    }
    
    
    @IBAction func submitChanges(sender: AnyObject) {
        
        println(self.clubNameField)
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

            
        }
    
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    
    }



    // Mark:- Textfield




