//
//  PinAnnotation.swift
//  VirtualTourist
//
//  Created by Ryan Rose on 8/30/15.
//  Copyright (c) 2015 GE. All rights reserved.
//

import Foundation
import MapKit

extension Pin: MKAnnotation  {
    
    // MARK: computed properties to conform to the MKAnnotation protocol
    var coordinate : CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    var subtitle: String {
        return location
    }
}