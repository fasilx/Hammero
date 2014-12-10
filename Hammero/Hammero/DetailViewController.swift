//
//  DetailViewController.swift
//  Hammero
//
//  Created by fasil fikreab on 12/4/14.
//  Copyright (c) 2014 fasil fikreab. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {



   

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()

        }
    }

    func configureView() {
        // Update the user interface for the detail item.
       
        self.title = self.detailItem?.valueForKey("name") as? String
        
        if let detail: AnyObject = self.detailItem {
            if let label = self.detailDescriptionLabel {
                
            label.text = self.detailItem?.valueForKey("name") as? String
            println(self.detailItem)
               
            }
        }
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

