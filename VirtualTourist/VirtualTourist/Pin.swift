//
//  Pin.swift
//  VirtualTourist
//
//  Created by Ryan Rose on 8/28/15.
//  Copyright (c) 2015 GE. All rights reserved.
//

import Foundation
import CoreData
import MapKit

//make Pin available to Objective-C code
@objc(Pin)

//make Pin a subclass of NSManagedObject
class Pin : NSManagedObject, MKAnnotation {
    
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Location = "location"
    }
    
    
    // We are promoting these four from simple properties, to Core Data attributes
    @NSManaged var id: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var location: String
    @NSManaged var photos: [Photo]
    
    // MARK: computed properties to conform to the MKAnnotation protocol
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var subtitle: String {
        return location
    }
    
    // Include this standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /**
    * The two argument init method
    *
    * The Two argument Init method. The method has two goals:
    *  - insert the new Pin into a Core Data Managed Object Context
    *  - initialze the Pin's properties from a dictionary
    */
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Pin" type.  This is an object that contains
        // the information from the VirtualTourist.xcdatamodeld file.
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Pin class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the
        // dictionary. This works in the same way that it did before we started on Core Data
        if let latitude = dictionary[Keys.Latitude] as? Double {
            self.latitude = latitude
        } else {
            self.latitude = 0.0
        }
        if let longitude = dictionary[Keys.Longitude] as? Double {
            self.longitude = longitude
        } else {
            self.longitude = 0.0
        }
        //generate uid in swift: http://stackoverflow.com/questions/24428250/generate-uuid-in-xcode-swift
        id = NSUUID().UUIDString
        location = dictionary[Keys.Location] as! String
    }
}