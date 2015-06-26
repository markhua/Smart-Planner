//
//  PlanListViewController.swift
//  Smart Planner
//
//  Created by Mark Zhang on 15/6/25.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

import UIKit
import CoreData

// Dispaly the plan list in a table view

class PlanListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        var error: NSError?
        fetchedResultsController.performFetch(&error)
        if let error = error {
            println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        fetchedResultsController.delegate = self

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Plan")
        // Fetched plans are sorted by date ascendingly
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let plan = fetchedResultsController.objectAtIndexPath(indexPath) as! Plan
        let CellIdentifier = "PlanCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! UITableViewCell
        
        if plan.photoUrl != "default" {
            
            // Build the filepath again because the document path in iOS simulator is likely to change in every run
            let filename = plan.photoUrl.lastPathComponent
            let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
            let pathArray = [dirPath, filename]
            let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!
            dispatch_async(dispatch_get_main_queue()){
                cell.imageView?.image = UIImage(contentsOfFile: fileURL.path!)
                cell.detailTextLabel?.text = "\(plan.name)\n\(plan.addr)"
                cell.textLabel?.text = self.convertDate(plan.date)
            }
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (editingStyle) {
        case .Delete:
            let plan = fetchedResultsController.objectAtIndexPath(indexPath) as! Plan
            sharedContext.deleteObject(plan)
            self.deleteFileFromPath(plan.photoUrl)
            CoreDataStackManager.sharedInstance().saveContext()
            
        default:
            break
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {

        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {

    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    // When endUpdates() is invoked, the table makes the changes visible.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    func convertDate (date: NSDate) -> String {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        return dateFormatter.stringFromDate(date)
    }
    
    func deleteFileFromPath(imageURL: String){
        let filename = imageURL.lastPathComponent
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let pathArray = [dirPath, filename]
        let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!
        
        var fileManager: NSFileManager = NSFileManager.defaultManager()
        var error: NSErrorPointer = NSErrorPointer()
        fileManager.removeItemAtPath(fileURL.path!, error: error)
    }
}
