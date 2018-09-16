//
//  mapViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 20/02/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var location = Location()
    var name = ""
    var address = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ((self.name.isEmpty) || (self.address.isEmpty) || (self.location.isEmpty)) {
            print("Error MapViewController - name, address. lat or lng not initialised before loading view")
        }

        self.mapView.showsUserLocation = true
        self.navigationItem.title = "Map"
        
        let location = CLLocationCoordinate2D(latitude:self.location.lat, longitude:self.location.lng)
        
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = self.name
        annotation.subtitle = self.address
        self.mapView.addAnnotation(annotation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
