//
//  VenueClient.swift
//  Smart Planner
//
//  Created by Mark Zhang on 15/6/24.
//  Copyright (c) 2015年 Mark Zhang. All rights reserved.
//

import Foundation
import UIKit

class VenueClient {
    
    var locations = [Venue]()
    var latitude: Double?
    var longitude: Double?
    
    func getVenuesFromFoursquare (near: String, query: String, view: UITableView){
        
        var methodArguments = [
            "client_id": "2RIDSLX5BQGIYSYNJCQTTA1TMC0DA1HI4ICN3NV40RCAMV1R",
            "client_secret": "DUMGEZH51R0ARYUFHTWD1SLZVKJXKWFNG5GV2VN31K3WY1RB",
            "v": "20150623",
            "near": near,
            "ll": "",
            "query": query,
            "limit": "10",
            "venuePhotos": "1"
        ]
        
        if latitude != nil && longitude != nil {
            let lat = Double(round(10*latitude!)/10)
            let long = Double(round(10*longitude!)/10)
            println(lat)
            println(long)
            methodArguments["ll"] = "\(lat),\(long)"
        }
        
        let session = NSURLSession.sharedSession()
        let urlString = "https://api.foursquare.com/v2/venues/explore" + escapedParameters(methodArguments)
        println(urlString)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let response = parsedResult.valueForKey("response") as? [String: AnyObject]{
                    if let groups = response["groups"] as? [[String: AnyObject]]{
                        var group = groups[0] as [String: AnyObject]
                        if let items = group["items"] as? [[String: AnyObject]]{
                            for item in items {
                                if let venue = item["venue"] as? [String: AnyObject]{
                                    self.parseResult(venue, view: view)
                                }
                            }
                        }
                        
                    }
                    
                    
                }
            }
        }
        
        task.resume()
        
        
    }
    
    func parseResult (venue: [String: AnyObject], view: UITableView){
        let venueName = venue["name"] as? String
        let venueRating = venue["rating"] as? Float
        var venueAddr: String?
        
        if let location = venue["location"] as? [String: AnyObject]{
            if let Addr1 = location["address"] as? String {
                venueAddr = Addr1
                if let Addr2 = location["crossStreet"] as? String {
                    venueAddr = "\(Addr1), \(Addr2)"
                }
            }
        }

        if let photo = venue["featuredPhotos"] as? [String: AnyObject]{
            if let featurephotos = photo["items"] as? [[String: AnyObject]]{
                var featurephoto = featurephotos[0] as [String: AnyObject]
                var prefix = featurephoto["prefix"] as! String
                var suffix = featurephoto["suffix"] as! String
                var photourl = "\(prefix)300x300\(suffix)"
                if let checkedUrl = NSURL(string: photourl) {
                    self.getDataFromUrl(checkedUrl) { data in
                        if let image = UIImage(data: data!) {
                            self.locations.append(Venue(Name: venueName, Photo: image, Rating: venueRating, Addr: venueAddr))
                            println("venue created")
                            dispatch_async(dispatch_get_main_queue()){
                                view.reloadData()
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    class func sharedInstance() -> VenueClient {
        
        struct Singleton {
            static var sharedInstance = VenueClient()
        }
        
        return Singleton.sharedInstance
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
}