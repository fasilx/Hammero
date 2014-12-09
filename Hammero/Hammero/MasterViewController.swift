//
//  MasterViewController.swift
//  Hammero
//
//  Created by fasil fikreab on 12/4/14.
//  Copyright (c) 2014 fasil fikreab. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var authViewController: AuthViewController? = nil
    
    var clubRef = Firebase(url:"https://peopler.firebaseio.com/clubs")
    var ref = Firebase(url: "https://peopler.firebaseio.com")
   
    var clubs  = NSArray()
    var auth: AnyObject? = nil
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
//        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
//            self.clearsSelectionOnViewWillAppear = false
//            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
//        }
        
        
//        ref.observeAuthEventWithBlock({ authData in
//            if authData != nil {
//                // user authenticated with Firebase
//                println(authData)
//                self.auth = authData
//            } else {
//                self.performSegueWithIdentifier("checkAuth", sender: self.navigationController)
//            }
//        })
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated with Firebase
                println(authData.uid)
                println(authData)
                println(authData.provider)
                println("masterview")
                self.auth = authData
            } else {
                self.performSegueWithIdentifier("checkAuth", sender: self)
            }
        })

        
    }
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(true)
//        
//        ref.observeAuthEventWithBlock({ authData in
//            if authData != nil {
//                // user authenticated with Firebase
//                println(authData)
//                self.auth = authData
//            } else {
//                self.performSegueWithIdentifier("checkAuth", sender: self.navigationController)
//            }
//        })
//        
//    }
    
    func  setupFirebase(){
        
        clubRef.observeEventType(.Value, withBlock: {
            snapshot in
            
                   self.clubs = snapshot.value.allValues
                   self.tableView.reloadData()
        })
    
    }
    
//    func checkAuth() {
//       
//        ref.observeAuthEventWithBlock({ authData in
//            if authData != nil {
//                // user authenticated with Firebase
//                println(authData)
//                self.auth = authData
//            } else {
//                // No user is logged in
//            }
//        })
//        
//    }
    @IBAction func sortClubs(sender: AnyObject) {
        
        println(sender.selectedSegmentIndex)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let segmentedControl = UISegmentedControl(items: ["leading", "following"])
//        segmentedControl.addTarget(self, action: "filterClub", forControlEvents: .ValueChanged)
//        // Do any additional setup after loading the view, typically from a nib.
//        self.navigationItem.titleView = segmentedControl
        
//        self.navigationItem.leftBarButtonItem = self.editButtonItem()

//        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
//        self.navigationItem.rightBarButtonItem = addButton
//        if let split = self.splitViewController {
//            let controllers = split.viewControllers
//            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
//        }
//    
            setupFirebase()

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


   //  MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
          
            let tableViewCell = sender as UITableViewCell
            let indexPath = tableView.indexPathForCell(tableViewCell)
            let controller = segue.destinationViewController as DetailViewController
            controller.detailItem = clubs[indexPath!.row]
                //                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
        }
        
        if segue.identifier == "checkAuth" {
            let controller = segue.destinationViewController as AuthViewController
            
        }
    }

   // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
       
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return clubs.count
    }

//    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {

//        
//    }
//

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let object: AnyObject? = clubs[indexPath.row]
        let imageString = object?.valueForKey("avatar") as? String
        let imageData = NSData(base64EncodedString: imageString!, options: .allZeros)
        
        
        
        cell.imageView?.clipsToBounds = true
        cell.imageView?.layer.cornerRadius = 5
        cell.imageView?.image = UIImage(data: imageData!)
        
        cell.textLabel!.text = object?.valueForKey("name") as? String
        cell.detailTextLabel?.text = object?.valueForKey("description") as? String
        cell.accessoryView?.setValue(object, forKey: "object")
    
//        cell.accessoryView?.setValue
        //cell.accessoryType = UITableViewCellAccessoryType.DetailButton
        
       
        
        
        
        return cell
        
    }
    
  
   

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            objects.removeObjectAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        } else if editingStyle == .Insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//        }
//    }


}

