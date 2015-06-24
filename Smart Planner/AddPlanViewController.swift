//
//  ViewController.swift
//  Smart Planner
//
//  Created by Mark Zhang on 15/6/23.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class AddPlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var queryTextField: UITextField!
    @IBOutlet weak var areaTextField: UITextField!
    @IBOutlet weak var areaSwitch: UISwitch!
    
    let locationManager = CLLocationManager()
    var planDate: String?
    


    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        if areaSwitch.on { areaTextField.enabled = false }
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            //println(self.locationManager.location.coordinate.longitude)
            //println(self.locationManager.location.coordinate.latitude)
            
        }
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "VenueCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        
        let venue = VenueClient.sharedInstance().locations[indexPath.row]
        
        dispatch_async(dispatch_get_main_queue()){
            cell.textLabel?.text = venue.name
            cell.detailTextLabel?.text = "\(venue.addr) \nRating: \(venue.rating)"
            cell.imageView!.image = venue.photo
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VenueClient.sharedInstance().locations.count
    }
    
    //Open student's URL in browser after clicking each cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("PlanDetailViewController")! as! PlanDetailViewController
        
        detailController.selectedVenueIndex = indexPath.row
        self.navigationController!.pushViewController(detailController, animated: true)
        
    }
    
    @IBAction func tapSwitch(sender: UISwitch) {
        
        if areaSwitch.on {
            areaTextField.enabled = false
        } else {
            areaTextField.enabled = true
        }
    }
    
    @IBAction func searchVenue(sender: UIButton) {
        VenueClient.sharedInstance().locations.removeAll(keepCapacity: true)
        VenueClient.sharedInstance().getVenuesFromFoursquare(areaTextField.text, query: queryTextField.text, view: tableView)
    }
    
    //Display notification with message string
    func notificationmsg (msgstring: String)
    {
        dispatch_async(dispatch_get_main_queue()){
            let controller = UIAlertController(title: "Notification", message: msgstring, preferredStyle: .Alert)
            controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        println("locations = \(locValue.latitude) \(locValue.longitude)")
        VenueClient.sharedInstance().latitude = locValue.latitude
        VenueClient.sharedInstance().longitude = locValue.longitude
        self.locationManager.stopUpdatingLocation()
    }

    /*@IBAction func datePickerAction(sender: AnyObject) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        self.planDate = dateFormatter.stringFromDate(datePicker.date)
        println(self.planDate!)
    }*/
}

