//
//  CalendarViewController.swift
//  Smart Planner
//
//  Created by Mark Zhang on 15/6/25.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

import UIKit
import CoreData

class CalendarViewController: UIViewController {
    
    var index = 5
    var year = 2015
    
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let month = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var dailystatus = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.monthLabel.text = "\(month[index]), \(year)"
        var i = 0
        while i < 31 {
            dailystatus.append(0)
            i++
        }
        getPlanForCurrentMonth()

    }
    
    func getPlanForCurrentMonth (){
        var error: NSError?
        
        fetchedResultsController.performFetch(&error)
        
        if let error = error {
            println("Unresolved error \(error), \(error.userInfo)")
            abort()
        } else {
            for object in fetchedResultsController.fetchedObjects as! [Plan] {
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy"
                let y = dateFormatter.stringFromDate(object.date)
                
                if y.toInt()! == self.year {
                    
                    dateFormatter.dateFormat = "MM"
                    let m = dateFormatter.stringFromDate(object.date)
                    if m.toInt()! - 1 == self.index {
                        dateFormatter.dateFormat = "dd"
                        let d = dateFormatter.stringFromDate(object.date)
                        
                        self.dailystatus[d.toInt()! - 1] = 1
                        println(y+m+d)
                    }
                }
                
            }
        }

    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Plan")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
        }()
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if index == 1 { return 28 }
        if index == 3 || index == 5 || index == 8 || index == 10 {
            return 30
        }
        return 31
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DayCell", forIndexPath: indexPath) as! CalendarCell
        cell.number.text = "\(indexPath.row + 1)"
        if self.dailystatus[indexPath.row] == 1 {
            cell.backgroundColor = UIColor.yellowColor()
        } else {
            cell.backgroundColor = UIColor(red: 1.0000, green: 0.9451, blue: 0.8000, alpha: 1)
        }
        return cell
    }

    @IBAction func nextMonth(sender: UIButton) {
        if index == 11 {
            index = 0
            year++
        } else {
            index++
        }
        monthLabel.text = "\(month[index]), \(year)"
        refreshMappingArray()
        getPlanForCurrentMonth()
        self.collectionView.reloadData()
    }
    
    @IBAction func lastMonth(sender: UIButton) {
        if index == 0 {
            index = 11
            year--
        } else {
            index--
        }
        monthLabel.text = "\(month[index]), \(year)"
        refreshMappingArray()
        getPlanForCurrentMonth()
        self.collectionView.reloadData()
    }
    
    func refreshMappingArray () {
        var i = 0
        while i < 31 {
            self.dailystatus[i] = 0
            i++
        }
        
    }

}
