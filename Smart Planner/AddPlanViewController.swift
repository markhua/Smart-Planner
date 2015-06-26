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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var queryTextField: UITextField!
    @IBOutlet weak var areaTextField: UITextField!
    @IBOutlet weak var areaSwitch: UISwitch!
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        if areaSwitch.on { areaTextField.enabled = false }
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // Get user's current location
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
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
            self.activityIndicator.hidden = true
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VenueClient.sharedInstance().locations.count
    }
    
    // Navigate to the detail view controller to make the plan after selecting the venue
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
    
    // The two textfields' text are verified and then passed to the search action
    @IBAction func searchVenue(sender: UIButton) {
        if queryTextField.text == "" {
            self.notificationmsg("The search field cannot be empty")
        } else {
            CLGeocoder().geocodeAddressString(self.areaTextField.text, completionHandler: {(placemarks, error)->Void in
                if  error == nil || self.areaSwitch.on {
                    
                    VenueClient.sharedInstance().locations.removeAll(keepCapacity: true)
                    VenueClient.sharedInstance().getVenuesFromFoursquare(self.areaTextField.text, query: self.queryTextField.text, view: self.tableView) {
                        success, result in
                        if !success {
                            self.notificationmsg(result!)
                        }
                    }
                    self.activityIndicator.hidden = false
                    
                } else {
                    self.notificationmsg("Invalid area")
                }
            })
    
        }
    }
    
    // Display notification with message string
    func notificationmsg (msgstring: String)
    {
        dispatch_async(dispatch_get_main_queue()){
            let controller = UIAlertController(title: "Notification", message: msgstring, preferredStyle: .Alert)
            controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // Get the current location and set to VenueClient
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        println("locations = \(locValue.latitude) \(locValue.longitude)")
        VenueClient.sharedInstance().latitude = locValue.latitude
        VenueClient.sharedInstance().longitude = locValue.longitude
        self.locationManager.stopUpdatingLocation()
    }

}

