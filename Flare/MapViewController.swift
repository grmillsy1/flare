//
//  ViewController.swift
//  Flare
//
//  Created by Georgia Mills on 06/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//


import UIKit
import MapKit
import Firebase
import FirebaseDatabase
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var flareArray = [Flare]()
    var databaseRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        
        // MARK: Upload an image to storage
        let storage = FIRStorage.storage()
        let storageRef = storage.referenceForURL("gs://flare-1ef4b.appspot.com")
//      let storageRef = storage.reference()
        let localFile = NSURL(string: "http://www.freedigitalphotos.net/images/img/homepage/87357.jpg")
        print("*********************")
        print(localFile)
        let fileRef = storageRef.child("images/")
        let uploadTask = fileRef.putFile(localFile!, metadata: nil) { metadata, error in
            if (error != nil) {
                print("inside if *********************")
                print(localFile)
                
                // Uh-oh, an error occurred!
            } else {
                print("inside else *********************")
                print(localFile)
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL
            }
        }

        

             
        // MARK: Retrieve flare from database
        
        databaseRef = FIRDatabase.database().reference().child("flares")
        databaseRef.observeEventType(.Value, withBlock: { (snapshot) in
            
            var newItems = [Flare]()
            for item in snapshot.children {
                let newFlare = Flare(snapshot: item as! FIRDataSnapshot)
                newItems.insert(newFlare, atIndex: 0)
            }
            
            self.flareArray = newItems
            self.mapView.delegate = self
            self.mapView.addAnnotations(self.flareArray)
            
        })
        { (error) in
                print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Location Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }
    
}

