//
//  Venue.swift
//  Smart Planner
//
//  Created by Mark Zhang on 15/6/23.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

import Foundation
import UIKit

// This class is used to create objects for Venue search results from the network

class Venue {
    var name: String
    var photo: UIImage
    var photoURL: String
    var rating: Float
    var addr: String
    var long: Double
    var lat: Double
    
    init (Name: String?, Photo: UIImage?, PhotoURL: String?, Rating: Float?, Addr: String?, Lat: Double?, Long: Double?){
        if Name != nil { name = Name! } else { name = "" }
        if Photo != nil { photo = Photo! } else { photo = UIImage(named: "Default")! }
        if Rating != nil { rating = Rating! } else { rating = 0 }
        if Addr != nil { addr = Addr! } else {addr = ""}
        if Lat != nil { lat = Lat! } else {lat = 0}
        if Long != nil { long = Long! } else {long = 0}
        if PhotoURL != nil { photoURL = PhotoURL! } else {photoURL = ""}
    }
}