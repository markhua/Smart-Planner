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
    
    // index: the current month index
    var index = 5
    
    // year: the current year
    var year = 2015
    
    // firstdayindex: the weekday index the first day of month is
    var firstdayindex = 0
    
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    // Plans in the selected month
    var planInMonth = [Plan]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let month = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

    // An array of 0 or 1, 0 means no event on that day, 1 means there is.
    var dailystatus = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        let date = NSDate()
        
        // Set the calendar to the current month
        let currentyear = self.convertDateToString(date, format: "yyyy")
        year = currentyear.toInt()!
        let currentmonth = self.convertDateToString(date, format: "MM")
        index = currentmonth.toInt()! - 1
        
        let firstdayofmonth = "\(currentyear)-\(currentmonth)-01"
        
        firstdayindex = getDayOfWeek(firstdayofmonth)! - 1
        
        self.monthLabel.text = "\(month[index]), \(year)"
        var i = 0
        
        // 38 covers the maximum number of cells required in each month
        while i < 38 {
            dailystatus.append(0)
            i++
        }
        getPlanForCurrentMonth()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadView()
    }
    
    // Get the plans in the month indicated by the selected month/year
    func getPlanForCurrentMonth (){
        var error: NSError?
        
        fetchedResultsController.performFetch(&error)
        
        if let error = error {
            println("Unresolved error \(error), \(error.userInfo)")
            abort()
        } else {
            for object in fetchedResultsController.fetchedObjects as! [Plan] {

                let y = self.convertDateToString(object.date, format: "yyyy")
                
                if y.toInt()! == self.year {

                    let m = self.convertDateToString(object.date, format: "MM")
                    if m.toInt()! - 1 == self.index {
                        self.planInMonth.append(object)

                        let d = self.convertDateToString(object.date, format: "dd")
                        
                        // Set the value at the specific index to 1 to indicate there's a plan
                        self.dailystatus[d.toInt()! - 1 + firstdayindex] = 1
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Lay out the collection view so that cells take up 1/7 of the width
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0 , left: 1, bottom: 0, right: 0)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
        
        let width = floor(self.collectionView.frame.size.width/7)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if index == 1 {
            if year % 4 == 0 {
                if year % 100 == 0 && year % 400 != 0 {
                    return 28 + firstdayindex
                } else {
                    return 29 + firstdayindex
                }
            } else {
                return 28 + firstdayindex
            }
        }
        if index == 3 || index == 5 || index == 8 || index == 10 {
            return 30 + firstdayindex
        }
        return 31 + firstdayindex
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DayCell", forIndexPath: indexPath) as! CalendarCell
        
        // Display the "Day" number in each cell since the first day of month
        let dayinmonth = indexPath.row + 1 - firstdayindex
        if dayinmonth > 0 {
            cell.number.text = "\(dayinmonth)"
            if self.dailystatus[indexPath.row] == 1 {
                cell.backgroundColor = UIColor.yellowColor()
            } else {
                cell.backgroundColor = UIColor(red: 1.0000, green: 0.9451, blue: 0.8000, alpha: 1)
            }
        } else {
            cell.number.text = ""
            cell.backgroundColor = UIColor(red: 1.0000, green: 0.9451, blue: 0.8000, alpha: 1)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.planInMonth.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
 
        let CellIdentifier = "PlanCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! UITableViewCell
        let plan = self.planInMonth[indexPath.row]
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd, HH:mm"
        cell.textLabel?.text = dateFormatter.stringFromDate(plan.date)
        cell.detailTextLabel?.text = "\(plan.name)\n\(plan.addr)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (editingStyle) {
        case .Delete:
            
            let plan = self.planInMonth[indexPath.row]
            planInMonth.removeAtIndex(indexPath.row)
            self.deleteFileFromPath(plan.photoUrl)
            sharedContext.deleteObject(plan)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            CoreDataStackManager.sharedInstance().saveContext()
            reloadView()

        default:
            break
        }
    }

    @IBAction func nextMonth(sender: UIButton) {
        if index == 11 {
            index = 0
            year++
        } else {
            index++
        }
        reloadView()
    }
    
    @IBAction func lastMonth(sender: UIButton) {
        if index == 0 {
            index = 11
            year--
        } else {
            index--
        }
        reloadView()
    }
    
    func convertDateToString(date: NSDate, format: String) -> String {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(date)
        
    }
    
    // reloadView method refresh the selected month/year, the calendar layout, the table view and collection view
    func reloadView(){
        
        monthLabel.text = "\(month[index]), \(year)"
        let firstdayofmonth = "\(year)-\(month[index])-01"
        firstdayindex = getDayOfWeek(firstdayofmonth)! - 1
        refreshMappingArray()
        
        self.planInMonth.removeAll(keepCapacity: false)
        getPlanForCurrentMonth()
        self.collectionView.reloadData()
        self.tableView.reloadData()
        
    }
    
    func refreshMappingArray () {
        var i = 0
        while i < 31 {
            self.dailystatus[i] = 0
            i++
        }
        
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
    
    // Returns the weekday index from specific date
    func getDayOfWeek(today:String)->Int? {
        
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let todayDate = formatter.dateFromString(today) {
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let myComponents = myCalendar.components(.CalendarUnitWeekday, fromDate: todayDate)
            let weekDay = myComponents.weekday
            return weekDay
        } else {
            return nil
        }
    }

}
