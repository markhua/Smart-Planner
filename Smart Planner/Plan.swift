//
//  Plan.swift
//  Smart Planner
//
//  Created by Mark Zhang on 15/6/24.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//


import UIKit
import CoreData

@objc(Plan)

// This is the class to store saved Plan, it's also stored in Core data

class Plan: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var addr: String
    @NSManaged var photoUrl: String
    @NSManaged var date: NSDate
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(venue: Venue, plandate: NSDate, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Plan", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        name = venue.name
        addr = venue.addr
        photoUrl = "default"
        let imageurl = NSURL(string: venue.photoURL)!
        
        //Write the image file to document directory
        if let imageData = NSData(contentsOfURL: imageurl) {
            let filepath = imageFileURL(venue.photoURL)
            imageData.writeToURL(filepath, atomically: true)
            photoUrl = filepath.path!
            //println(photoUrl)
        }
        
        date = plandate
        
    }
    
    func imageFileURL(url: String) ->  NSURL {
        let filename = url.lastPathComponent
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let pathArray = [dirPath, filename]
        let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!
        return fileURL
    }

}
