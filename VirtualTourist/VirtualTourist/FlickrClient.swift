//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Ryan Rose on 9/6/15.
//  Copyright (c) 2015 GE. All rights reserved.
//  FlickrClient based on methods found in FlickFinder by Jarrod Parkes
//

import Foundation

let BASE_URL = "https://api.flickr.com/services/rest/"
let METHOD_NAME = "flickr.photos.search"
let API_KEY = "bdb467c0490d10500457afbee64a2350"
let EXTRAS = "url_m"
let SAFE_SEARCH = "1"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"
let PHOTOS_PER_PAGE = "25"
let BOUNDING_BOX_HALF_WIDTH = 1.0
let BOUNDING_BOX_HALF_HEIGHT = 1.0
let LAT_MIN = -90.0
let LAT_MAX = 90.0
let LON_MIN = -180.0
let LON_MAX = 180.0

class FlickrClient {
    
    func searchPhotosByLatLon(lat: Double, long: Double, page: Int, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        println("Searching...")
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "bbox": createBoundingBoxString(lat, longitude: long),
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK,
            "per_page": PHOTOS_PER_PAGE,
            "page": page
        ]
        getImageFromFlickrBySearch(methodArguments as! [String : AnyObject], completionHandler: completionHandler)
    }
    
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    /* Function makes first request to get a random page, then it makes a request to get an image with the random page */
    func getImageFromFlickrBySearch(methodArguments: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
                
                var parsingError: NSError? = nil
                
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let error = parsingError {
                    completionHandler(result: nil, error: error)
                } else {
                    completionHandler(result: parsedResult, error: nil)
                }
            }
        }
        
        task.resume()
    }
    
    // Download a single image from Flickr
    func getSingleImage(filePath: String, completionHandler :(imageDate: NSData?, error:NSError?) -> Void) {
        
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: filePath)!
        let request = NSURLRequest(URL: url)
        
        // Make the request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                println("FlickrClient: getSingleImage error: \(error)")
                completionHandler(imageDate: data, error: error)
            } else {
                completionHandler(imageDate: data, error: nil)
            }
        }
        
        task.resume()
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
    
    //MARK:- SharedInstance
    
    class func sharedInstance()-> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }

}