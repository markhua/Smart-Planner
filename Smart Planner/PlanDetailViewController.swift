//
//  PlanDetailViewController.swift
//  Smart Planner
//
//  Created by Mark Zhang on 15/6/24.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

import UIKit
import Foundation

class PlanDetailViewController: UIViewController {
    
    var selectedVenueIndex: Int?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var AddrTextField: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var addPlanButton: UIButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        let selectedVenue = VenueClient.sharedInstance().locations[selectedVenueIndex!]
    
        self.imageView.image  = selectedVenue.photo
        self.nameTextField.text = selectedVenue.name
        self.AddrTextField.text = "\(selectedVenue.addr) \nRating: \(selectedVenue.rating)"
    }
    
    
    
}
