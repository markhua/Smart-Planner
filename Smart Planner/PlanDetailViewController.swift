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

class PlanDetailViewController: UIViewController {
    
    var selectedVenueIndex: Int?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var AddrTextField: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var addPlanButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
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
        
    }
    
    
    
}
