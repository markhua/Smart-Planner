//
//  PlanDetailViewController.swift
//  Smart Planner
//
//  Created by Mark Zhang on 15/6/24.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreData

class PlanDetailViewController: UIViewController {
    
    var selectedVenueIndex: Int?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var AddrTextField: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var addPlanButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        let selectedVenue = VenueClient.sharedInstance().locations[selectedVenueIndex!]
    
        self.imageView.image  = selectedVenue.photo
        self.nameTextField.text = selectedVenue.name
        self.AddrTextField.text = "\(selectedVenue.addr) \nRating: \(selectedVenue.rating)"
        
        // Set the mapView on the top and add the pin
        var center =  CLLocationCoordinate2D(latitude: selectedVenue.lat, longitude: selectedVenue.long)
        var span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = selectedVenue.name
        mapView.addAnnotation(annotation)
        
        let error: NSErrorPointer = nil

        let fetchRequest = NSFetchRequest(entityName: "Plan")
        
        // Execute the Fetch Request
        let results = sharedContext.executeFetchRequest(fetchRequest, error: error)
        
        // Check for Errors
        if error != nil {
            println("Error in fectchAllActors(): \(error)")
        }else{
            for result in results as! [Plan] {
                println(result.name)
                println(result.addr)
                println(result.date)
                println(result.photoUrl)
            }
        }

        
    }
    @IBAction func updateDate(sender: UIDatePicker) {
    }
    
    @IBAction func addPlan(sender: UIButton) {
        
        let selectedVenue = VenueClient.sharedInstance().locations[selectedVenueIndex!]
        var plan = Plan(venue: selectedVenue, plandate: datePicker.date, context: sharedContext)
        CoreDataStackManager.sharedInstance().saveContext()
        
        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
    
}
