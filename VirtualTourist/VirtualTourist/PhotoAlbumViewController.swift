//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Ryan Rose on 9/6/15.
//  Copyright (c) 2015 GE. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate {
    var currentPin: Pin!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // set initial location in Honolulu
        let initialLocation = CLLocation(latitude: currentPin.latitude, longitude: currentPin.longitude)
        centerMapOnLocation(initialLocation)
        
        //add selected Pin to our map view
        let pa = MKPointAnnotation()
        pa.coordinate = currentPin.coordinate
        pa.title = currentPin.title
        self.mapView.addAnnotation(pa)
    }
    
    //helper method from: http://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}