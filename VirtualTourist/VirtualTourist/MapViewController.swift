//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Ryan Rose on 8/28/15.
//  Copyright (c) 2015 GE. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //http://stackoverflow.com/questions/3959994/how-to-add-a-push-pin-to-a-mkmapviewios-when-touching
        //target gesture recognizer on our map
        var longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "addPin:")
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
        
        //load any saved Pins
        fetchPins()
        
        // set initial location in Honolulu
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        centerMapOnLocation(initialLocation)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext!
    }
    
    //helper method from: http://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: Gesture support
    
    //http://stackoverflow.com/questions/3959994/how-to-add-a-push-pin-to-a-mkmapviewios-when-touching
    func addPin(gestureRecognizer: UIGestureRecognizer) {
        println("gesture recognized")
        if gestureRecognizer.state == UIGestureRecognizerState.Ended {
            let touchPoint = gestureRecognizer.locationInView(gestureRecognizer.view!)
            let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            
            let temporaryTitle = "\(touchMapCoordinate.latitude), \(touchMapCoordinate.longitude)"
            let dictionary: [String: AnyObject] = [Pin.Keys.Latitude: touchMapCoordinate.latitude,
                Pin.Keys.Longitude: touchMapCoordinate.longitude, Pin.Keys.Location: temporaryTitle]
            
            let pin = Pin(dictionary: dictionary, context: self.sharedContext)
            CoreDataManager.sharedInstance.saveContext()
        }
    }
    
    private func reverseGeocode(annotation: Pin) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        //http://stackoverflow.com/questions/24345296/swift-clgeocoder-reversegeocodelocation-completionhendler-closure
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            var placemark:CLPlacemark!
            
            if error == nil && placemarks.count > 0 {
                placemark = placemarks[0] as! CLPlacemark
                
                var addressString : String = ""
                if placemark.subThoroughfare != nil {
                    addressString = placemark.subThoroughfare + " "
                }
                if placemark.thoroughfare != nil {
                    addressString = addressString + placemark.thoroughfare + ", "
                }
                if placemark.postalCode != nil {
                    addressString = addressString + placemark.postalCode + " "
                }
                if placemark.locality != nil {
                    addressString = addressString + placemark.locality + ", "
                }
                if placemark.administrativeArea != nil {
                    addressString = addressString + placemark.administrativeArea + " "
                }
                if placemark.country != nil {
                    addressString = addressString + placemark.country
                }
                
                println(addressString)
                //update Pin and save
                annotation.location = addressString
                CoreDataManager.sharedInstance.saveContext()
            }
            
        })
    }
    
    private func fetchPins() {
        var error: NSError? = nil
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        let results = self.sharedContext.executeFetchRequest(fetchRequest, error: &error)
        if error != nil {
            displayError("Unable to load saved pins")
            return
        }
        for pin in results as! [Pin] {
            println("adding pin")
            self.mapView.addAnnotation(pin)
        }
    }

}
