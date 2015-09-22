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
    //keep track of tapped cells
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    
    //keep track of current page number for Flickr photos
    var currentPageNumber : Int = 0
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var deleteSelectedButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
   
    //collection view constants
    private let reuseIdentifier = "FlickrCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance.managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "location == %@", self.currentPin)
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchResultController
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = false
        //disable delete button onload
        deleteSelectedButton.enabled = false
        
        //set view controller as the collection view's delegate and data source
        collectionView.delegate = self
        
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
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        //reset before updates commence
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
    }
    
    // Insert, Update and delete collection view cells when objects are inserted, updated and deleted
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            deletedIndexPaths.append(indexPath!)
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        //performBatchUpdates will animate any changes to the collection view performed inside the block
        //http://www.raywenderlich.com/78551/beginning-ios-collection-views-swift-part-2
        collectionView.performBatchUpdates({ () -> Void in
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
    
    // MARK: actions
    
    @IBAction func newCollection(sender: AnyObject) {
        newCollectionButton.enabled = false
        deleteAllPhotosAndCreateNewCollection()
    }
    
    @IBAction func deleteSelected(sender: AnyObject) {
        deleteSelectedButton.enabled = false
        deleteSelectedPhotos()
    }
    
    func  deleteSelectedPhotos() {
        var photos = [Photo]()
        //loop through the selected cells so we can get info of the photos to remove
        for index in selectedIndexes {
            //add the Photo to our array of items to remove
            photos.append(fetchedResultsController.objectAtIndexPath(index) as! Photo)
        }
        //loop through the array of photos to remove and remove them from Core Data
        for photo in photos {
            sharedContext.deleteObject(photo)
        }
        //persist our changes
        CoreDataManager.sharedInstance.saveContext()
        //reset
        selectedIndexes = [NSIndexPath]()
        newCollectionButton.enabled = true
    }
    
    func deleteAllPhotosAndCreateNewCollection() {
        currentPageNumber++
        
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
        CoreDataManager.sharedInstance.saveContext()
        loadNewCollection(currentPageNumber)
    }
    
    //Load new flickr image collection by taking into account next page number
    func loadNewCollection(currentPageNumber: Int) {
        FlickrClient.sharedInstance().searchPhotosByLatLon(currentPin.latitude, long: currentPin.longitude, page: currentPageNumber, completionHandler: {
            JSONResult, error in
            if let error = error {
                println(error)
            } else {
                if let photosDictionary = JSONResult.valueForKey("photos") as? [String:AnyObject] {
                    
                    var totalPhotosVal = 0
                    if let totalPhotos = photosDictionary["total"] as? String {
                        totalPhotosVal = (totalPhotos as NSString).integerValue
                    }
                    
                    if totalPhotosVal > 0 {
                        if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                            
                            for (var i = 0; i < photosArray.count; i++) {
                                let photoDict = photosArray[i] as [String: AnyObject]
                                dispatch_async(dispatch_get_main_queue(), {
                                    let photo = Photo(dictionary: photoDict, pin: self.currentPin, context: self.sharedContext)
                                })
                            }
                            //persist photos to core data
                            dispatch_async(dispatch_get_main_queue()) {
                                self.newCollectionButton.enabled = true
                                CoreDataManager.sharedInstance.saveContext()
                            }
                            
                        } else {
                            println("Cant find key 'photo' in \(photosDictionary)")
                        }
                    } else {
                        println("No photos found for location")
                    }
                } else {
                    println("Cant find key 'photos' in \(JSONResult)")
                }
            }
        })

    }
}

//http://www.raywenderlich.com/78550/beginning-ios-collection-views-swift-part-1
extension PhotoAlbumViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    //1
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    //2
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    //3
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        // Configure the cell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    //4
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        
        //add/remove the tapped cell to our array
        if let index = find(selectedIndexes, indexPath) {
            selectedIndexes.removeAtIndex(index)
        } else {
            selectedIndexes.append(indexPath)
        }
        
        //Then configure the cell
        configureCell(cell, atIndexPath: indexPath)
        
        //toggle the delete button
        deleteSelectedButton.enabled = true
    }
    
    //displays individual images in collection cell either from file cache or downloaded from API
    func configureCell(cell:PhotoCollectionViewCell, atIndexPath indexPath:NSIndexPath) {
        
        //create a placeholder
        let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        var cellImage = UIImage(named: "imagePlaceholder")
        cell.photoImage.image = nil
        
        //do we have a cached image to display or do we need to download one?
        if photo.image != nil {
            cellImage = photo.image
        } else {
            //create a loading indicator to display for each photo as it downloads from Flickr
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            cell.addSubview(activityIndicator)
            activityIndicator.frame = cell.bounds
            activityIndicator.startAnimating()
            
            //initiate the download
            FlickrClient.sharedInstance().getSingleImage(photo.url) {
                data, error in
                
                if let downloaderror = error {
                    activityIndicator.removeFromSuperview()
                    print("Flickr getSingleImage download error: \(downloaderror)")
                }
                if let imageData = data {
                    
                    // Create the image
                    let image = UIImage(data: imageData)
                    
                    // update the cell later, on the main thread
                    dispatch_async(dispatch_get_main_queue(), {
                        // Update the model so that information gets cached
                        photo.image = image
                        
                        activityIndicator.removeFromSuperview()
                        cell.photoImage.image = image
                        
                        //cache the image to the file system
                        CoreDataManager.sharedInstance.saveContext()
                    })
                } else {
                    activityIndicator.removeFromSuperview()
                    println("Unable to create image from Flickr download")
                }
            }
        }
        
        cell.photoImage.image = cellImage
        
        //toggle visibility of the delete button for each cell
        if let index = find(selectedIndexes, indexPath) {
            cell.photoImage.alpha = 0.5
        } else {
            cell.photoImage.alpha = 1.0
        }
    }
}