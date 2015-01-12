//
//  Auth.swift
//  Hammero
//
//  Created by fasil fikreab on 12/8/14.
//  Copyright (c) 2014 fasil fikreab. All rights reserved.
//

import UIKit

class Auth: UIViewController, UITextFieldDelegate {

    var ref = Firebase(url: "https://peopler.firebaseio.com")
    
    @IBOutlet weak var usename: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    
    @IBOutlet weak var error: UILabel!
    
    @IBAction func login(sender: AnyObject) {
        
     self.auth()
       
    }
 
  
    @IBAction func dismiss(sender: AnyObject) {
        
    }
    
    
    func auth(){
        
        ref.authUser(self.usename.text, password: self.password.text) {
            error, authData in
            if error != nil {
                // an error occured while attempting login
                 self.error.text = error.localizedDescription
                println(error.localizedDescription)
            } else {
                // user is logged in, check authData for data
                println(authData)
                
               
            }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usename.delegate = self
        self.password.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        usename.resignFirstResponder()
        password.resignFirstResponder()
        
        return true
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
