//
//  PubCrawlMapViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 28/02/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit
import MapKit

class PubCrawlMapViewController: UIViewController {
    
    var listOfPubHeaders = ListOfPubs()
    var pubCrawlName = ""
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ((self.listOfPubHeaders.isEmpty) || (self.pubCrawlName.isEmpty) ) {
            print("Error PubCrawlMapViewController - lisfOfPubs or pubCrawlName not initialised before loading view")
        }
        
        mapView.showsUserLocation = true
        mapView.setRegion(self.getRegion(listOfPubs: self.listOfPubHeaders), animated:true)

        self.navigationItem.title = self.pubCrawlName
        
        self.addPubstoMap()

    }

    func getRegion(listOfPubs:ListOfPubs) -> MKCoordinateRegion {
        
        switch listOfPubs.pubHeaders.count {
            case 0:
                return MKCoordinateRegion()
            case 1:
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let startLocation = CLLocationCoordinate2D( latitude:listOfPubs.pubHeaders[0].location.lat, longitude:listOfPubs.pubHeaders[0].location.lng )
                return MKCoordinateRegion(center: startLocation, span: span)
            default:
                var minLat = 180.0
                var maxLat = -180.0
                var minLng = 180.0
                var maxLng = -180.0
                
                for pubHeader in listOfPubs.pubHeaders {
                    if pubHeader.location.lat < minLat { minLat = pubHeader.location.lat }
                    if pubHeader.location.lat > maxLat { maxLat = pubHeader.location.lat }
                    if pubHeader.location.lng < minLng { minLng = pubHeader.location.lng }
                    if pubHeader.location.lng > maxLng { maxLng = pubHeader.location.lng }
                    
                }
                
                let span = MKCoordinateSpanMake(2.3 * abs(maxLat - minLat), 2.3 * abs(maxLng - maxLng))
                let startLocation = CLLocationCoordinate2D(latitude:minLat + (maxLat - minLat)/2, longitude: minLng + (maxLng - minLng)/2 )
                
                return MKCoordinateRegion(center: startLocation, span: span)
        }
        
    }
    
    func addPubstoMap() {
        for pubHeader in self.listOfPubHeaders.pubHeaders
        {
            let location = CLLocationCoordinate2D(latitude:pubHeader.location.lat, longitude:pubHeader.location.lng )
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = pubHeader.name
            annotation.subtitle = pubHeader.town
            mapView.addAnnotation(annotation)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
