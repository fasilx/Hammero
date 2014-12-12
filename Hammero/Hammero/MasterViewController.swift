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
    
    var ref = Firebase(url: "https://peopler.firebaseio.com")
    var clubsRef = Firebase(url:"https://peopler.firebaseio.com/clubs")
    var usersRef = Firebase(url: "https://peopler.firebaseio.com/users")
    
    var clubs  = NSMutableArray()
    var user: FAuthData? = nil
    
    // vars for tableView.selectedSegmentIndex IBaction
    
    var removedIndexes = NSMutableIndexSet()
    
    var buffer = NSMutableArray()
   
    
    
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    
    //  MARK: - Actions and Outlets
    
    @IBAction func sortClubs(sender: AnyObject) {

        if(sender.selectedSegmentIndex == 1)
        {
       
            var indexes = [NSIndexPath]()
     
            for index in 0...clubs.count - 1 {
                if(clubs[index].valueForKey("founders_id") as? String != user!.uid as String){
                    indexes.append(NSIndexPath(forRow: index, inSection: 0))
                    removedIndexes.addIndex(index)
                    
                }
                println(clubs[index].valueForKey("name"))
            }
            
            self.clubs.removeObjectsAtIndexes(removedIndexes)
            println("\n")
            println("imediately after remove")
            for i in 0...clubs.count - 1{
                println(clubs[i].valueForKey("name"))
            }

            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths(indexes, withRowAnimation: .Automatic)
            tableView.endUpdates()
            

    
        }else{
            clubs = buffer.mutableCopy() as NSMutableArray
            tableView.reloadData()
        }
    }
    
    
    
    
    //  MARK: - Helpers
    
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
        
        usersRef.childByAppendingPath(self.user!.uid + "/clubs").observeEventType(.Value, withBlock: {
            dataSnapshot in
            for index in dataSnapshot.value.allKeys{
                self.getClubs(index as String)
            }
        })
        
    }
    
    func getClubs(club: String){
        
        clubsRef.childByAppendingPath("/" + club).observeEventType(.Value, withBlock: {
            snapshot in
            
            self.clubs.addObject(snapshot.value)
            self.buffer.addObject(snapshot.value)
            self.tableView.reloadData()
        })
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.user == nil {
            checkAuth()
        }else{
            setupFirebase()
        }
        
        
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
        
        if segue.identifier == "showMessages" {
            let controller = segue.destinationViewController as GroupChatViewController
            
        }
    }
    
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return clubs.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let object: AnyObject? = clubs[indexPath.row]
        let imageString = object?.valueForKey("avatar") as? String
        let imageData = NSData(base64EncodedString: imageString!, options: .allZeros)
        let founders_id: String? = clubs[indexPath.row].valueForKey("founders_id") as? String
        
        if (founders_id == user?.uid){
            
            cell.accessoryType = UITableViewCellAccessoryType.DetailButton
            
        }else
        {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        
        cell.imageView?.clipsToBounds = true
        cell.imageView?.layer.cornerRadius = 5
        cell.imageView?.image = UIImage(data: imageData!)
        
        cell.textLabel!.text = object?.valueForKey("name") as? String;
        cell.detailTextLabel?.text = object?.valueForKey("description") as? String;
        
        
        
        
        
        return cell
        
    }
    
    
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
}

