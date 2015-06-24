//
//  Venue.swift
//  Smart Planner
//
//  Created by Mark Zhang on 15/6/23.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

import Foundation
import UIKit

class Venue {
    var name: String
    var photo: UIImage
    var rating: Float
    var addr: String
    
    init (Name: String?, Photo: UIImage?, Rating: Float?, Addr: String?){
        if Name != nil { name = Name! } else { name = "" }
        if Photo != nil { photo = Photo! } else { photo = UIImage(named: "Default")! }
        if Rating != nil { rating = Rating! } else { rating = 0 }
        if Addr != nil { addr = Addr! } else {addr = ""}
    }
}