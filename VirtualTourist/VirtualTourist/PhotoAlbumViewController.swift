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


class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    var currentPin: Pin!
    
    var selectedIndexes = [NSIndexPath]()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var deleteSelectedButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
   
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "location == %@", self.currentPin.location)
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchResultController
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = false
        //disable delete button onload
        deleteSelectedButton.enabled = false
        
        // Start the fetched results controller
        var error: NSError?
        fetchedResultsController.performFetch(&error)
        if let error = error {
            println("Error performing initial fetch: \(error)")
        }
        fetchedResultsController.delegate = self
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //set cell layout to 3 cells per row
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = floor(self.collectionView.frame.size.width/3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }
    
    //MARK:- UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    //displays individual images in collection cell either from file cache or downloaded from API
    func configureCell(cell:PhotoCollectionViewCell, atIndexPath indexPath:NSIndexPath) {
        
        //create a placeholder image and display during API image download
        let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        var cellImage = UIImage(named: "imagePlaceholder")
        cell.photoImage.image = nil
        
        // Set the flickr image if already available (from hard disk or image cache)
        if photo.image != nil {
            cellImage = photo.image
        } else {
            
            //download image from API and save to cache
            
        }
        
        cell.photoImage.image = cellImage
    }
}