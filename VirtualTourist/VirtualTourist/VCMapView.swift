//
//  VCMapView.swift
//  VirtualTourist
//
//  Created by Ryan Rose on 8/28/15.
//  Copyright (c) 2015 GE. All rights reserved.
//  Extension idea from: http://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial
//

import Foundation
import UIKit
import MapKit

extension MapViewController: MKMapViewDelegate {
    
    // https://www.hackingwithswift.com/read/19/3/annotations-and-accessory-views-mkpinannotationview
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? Pin {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
                view.animatesDrop = true
                view.draggable = true
            }
            return view
        }
        return nil
    }
    
    //make pin draggable by user: http://stackoverflow.com/questions/29776853/ios-swift-mapkit-making-an-annotation-draggable-by-the-user
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch (newState) {
        case .Starting:
            view.dragState = .Dragging
        case .Ending, .Canceling:
            view.dragState = .None
        default: break
        }
    }
    
    //transition to PhotoAlbumViewController when user taps the map location annotation
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control != annotationView.rightCalloutAccessoryView { return }
        
        let selectedPin = annotationView.annotation as! Pin
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
        //set selected Pin before transitioning to next view
        controller.currentPin = selectedPin
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //save map position after user moves map and/or zooms
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
}