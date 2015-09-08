//
//  Photo.swift
//  VirtualTourist
//
//  Created by Ryan Rose on 8/28/15.
//  Copyright (c) 2015 GE. All rights reserved.
//

import Foundation
import CoreData
import UIKit

//make Photo available to Objective-C code
@objc(Photo)

//make Pin a subclass of NSManagedObject
class Photo : NSManagedObject {
    
    struct Keys {
        static let ID = "id"
        static let Title = "title"
        static let File = "file"
        static let Url = "url"
    }
    
    
    // We are promoting these four from simple properties, to Core Data attributes
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var file: String?
    @NSManaged var url: String
    //manage relationship in Core Data
    @NSManaged var location: Pin?
    
    
    var image: UIImage? {
        get {
            return ImageCache().imageWithIdentifier(id)
        }
        set {
            ImageCache().storeImage(newValue, withIdentifier: id)
        }
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
    
    init(dictionary: [String : AnyObject], pin: Pin, context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Pin" type.  This is an object that contains
        // the information from the VirtualTourist.xcdatamodeld file.
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Pin class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the
        // dictionary. This works in the same way that it did before we started on Core Data
        title = dictionary[Keys.Title] as! String
        id = dictionary[Keys.ID] as! String
        file = dictionary[Keys.File] as! String?
        url = dictionary[Keys.Url] as! String
        self.location = pin
    }
}