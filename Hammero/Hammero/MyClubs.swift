

//
//  MyClubs.swift
//  Hammero
//
//  Created by fasil fikreab on 12/4/14.
//  Copyright (c) 2014 fasil fikreab. All rights reserved.
//

import UIKit


class MyClubs: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var editMyClubs: EditMyClubs? = nil
    var auth: Auth? = nil
   
    
    var ref = Firebase(url: "https://peopler.firebaseio.com")
    var clubsRef = Firebase(url:"https://peopler.firebaseio.com/clubs")
    var usersRef = Firebase(url: "https://peopler.firebaseio.com/users")
    
    var clubs  = NSMutableArray()
    var buffer = NSMutableArray()
    
    var user: FAuthData? = nil
    
    // vars for tableView.selectedSegmentIndex IBaction
    
    var removedIndexes = NSMutableIndexSet()
    
    var filteredClubs: [AnyObject] = []
   
   
    
    
    @IBOutlet var searchClubs: UISearchBar!
    

    
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
            }
            
            self.clubs.removeObjectsAtIndexes(removedIndexes)

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
            
            var temp: AnyObject = snapshot.value
            temp.addEntriesFromDictionary(["clubID": snapshot.key])

            self.clubs.addObject(temp)
            self.buffer.addObject(temp)
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let instance = MyClubsSingleton.sharedInstance
        if(instance.getClubModification()){
             println("club Modified")
             println(instance.getRow())
            clubs[instance.getRow()] = instance.getClub()
            buffer[instance.getRow()] = instance.getClub()
            println(instance.getClub().valueForKey("name"))
            println( clubs[instance.getRow()].valueForKey("name"))
        }
       

        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //  MARK: - Segues
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//
//        
//        if segue.identifier == "checkAuth" {
//            let controller = segue.destinationViewController as Auth
//            
//        }
//        
//        if segue.identifier == "showMessages" {
//            let controller = segue.destinationViewController as GroupChat
//            
//        }
//    }
    
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.filteredClubs.count
        } else {
            return self.clubs.count
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as MyClubsCell
        
     // println(cell)
     
        if tableView == self.searchDisplayController!.searchResultsTableView {
             let object: AnyObject? = filteredClubs[indexPath.row]
        } else {
             let object: AnyObject? = clubs[indexPath.row]
        }
        
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
        
        
        
        let clubAvatar = UIImage(data: imageData!)
        let clubName = object?.valueForKey("name") as? String
        let clubDescription = object?.valueForKey("description") as? String
        
        // temp values
        let clubFounder =    "me"
        

        
        cell.avatar.layer.cornerRadius =  cell.avatar.frame.width/2 // circular avatar
        
        cell.avatar.layer.borderColor = UIColor.lightGrayColor().CGColor

        cell.avatar.layer.borderWidth = 2.0
        
        
//      
//      
//       cell.avatar.layer.
//       cell.avatar.layer.borderWidth = 2.0
////       cell.avatar.layer.borderColor = UIColor.blackColor()
//       cell.avatar.clipsToBounds = true
//        
//       
        
        cell.setCell(clubName!, clubDescription: clubDescription!, clubFounder: clubFounder, avatar: clubAvatar!)
       
       
        return cell
        
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
        let club: AnyObject = clubs[indexPath.row]
        let instance = MyClubsSingleton.sharedInstance
        instance.setClub(club, atRow: indexPath.row)
        println("am here \(indexPath.row)")
        println(instance.getRow())
        println(clubs[indexPath.row].valueForKey("clubID"))
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
           let instance = MyClubsSingleton.sharedInstance
            instance.setClub(clubs[indexPath.row], atRow: indexPath.row)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    // Mark: - Search Bar
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
       
        let arr : [AnyObject] = clubs
        self.filteredClubs = arr.filter({(s : AnyObject) -> Bool in
           
            let stringMatch = s.valueForKey("name") as String
            println(stringMatch.rangeOfString(searchString) != nil)
            return stringMatch.rangeOfString(searchString) != nil
            
            })
        println(filteredClubs)
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
       searchBar.endEditing(true)
    }
    
    
}

