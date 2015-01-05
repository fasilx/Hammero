//
//  ChatLayout.swift
//  Hammero
//
//  Created by fasil fikreab on 12/31/14.
//  Copyright (c) 2014 fasil fikreab. All rights reserved.
//

import UIKit

class ChatLayout: UICollectionViewLayout {
    
    
    var layoutInfo = NSMutableArray()
   
    var doneLoading = false
    
    var viewKind = "Cell"
    
    var count = 0
    
    override func prepareLayout() {
       
        super.prepareLayout()
        
        
        
        let doneLoading = NSNotificationCenter.defaultCenter()
        doneLoading.addObserver(self, selector: "reloadingIsDone:", name: "doneReloading", object: nil)
        //println(numberOfSections)
        
        var newLayoutInfo = NSMutableArray()
       
       
        
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        let numberOfSections = (self.collectionView?.numberOfSections())!
        
  
                
        
        if(self.doneLoading){
            
            for section in 0...numberOfSections - 1{
                let numberOfItemsInSection =  (self.collectionView?.numberOfItemsInSection(section))!
                
                var cellLayoutInfo = NSMutableArray()
                
                for item in 0...numberOfItemsInSection - 1{
                    
                    
                    let indexPath = NSIndexPath(forItem: item, inSection: section)
                    let itemAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                   // var indexPath = NSIndexPath(forItem: item, inSection: section)
                    itemAttributes.frame = self.frameForCellAtIndexPath(indexPath)
                    
                    //println(indexPath)
                    cellLayoutInfo[item] = itemAttributes
                }
                 self.layoutInfo[section]  = cellLayoutInfo
            }
            
            
            
        }
        
      
        
    }
    
    
    
    func reloadingIsDone (note: NSNotification){
        
        self.doneLoading = true
    }
    
    
    func frameForCellAtIndexPath(indexPath: NSIndexPath) -> CGRect{
        
        println("I got here in one peace...")
        var x = CGFloat(indexPath.section)
        var y = CGFloat(indexPath.section)
//       let cell = self.collectionView?.dequeueReusableCellWithReuseIdentifier("MessageView", forIndexPath: indexPath) as UICollectionViewCell
        
     return CGRectMake(40, 40, 50, 50)
        
    }
    
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        println("layoutAttributesForItemAtIndexPath")
        return self.layoutInfo[indexPath.section][indexPath.item] as UICollectionViewLayoutAttributes
    }
    
//    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
//        var temp = [self.layoutInfo.count]
//        
//        return temp
//        
//        
//    }
  
    
    override func collectionViewContentSize() -> CGSize {
 
        let contentWidth : CGFloat = 320.0
        
       println( self.collectionView?.contentSize.height)
       
            // Scroll vertically to display a full day
      //
       
        
        
            return CGSizeMake((self.collectionView?.frame.width)!, 10000)
    }
    
    

    
 
}
