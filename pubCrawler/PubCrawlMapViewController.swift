//
//  PubCrawlMapViewController.swift
//  pubCrawler
//
//  Created by Michael Neilens on 28/02/2016.
//  Copyright © 2016 Michael Neilens. All rights reserved.
//

import UIKit
import MapKit

class PubCrawlMapViewController: AbstractViewController,MKMapViewDelegate {
    
    var listOfPubHeaders = ListOfPubs()
    var pubCrawlName = ""
    var pubHeaderSelected = PubHeader()
    
    private var newListOfPubHeaders = [PubHeader]()
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ((self.listOfPubHeaders.isEmpty) || (self.pubCrawlName.isEmpty) ) {
            print("Error PubCrawlMapViewController - lisfOfPubs or pubCrawlName not initialised before loading view")
        }
        
        if self.listOfPubHeaders.pubHeaders[0].location.isEmpty {
            self.getPubLocations()
        } else {
            self.setUpMap()
            self.addPubstoMap()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = listOfPubHeaders.listTitle
        mapView.delegate = self
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.delegate = nil
    }
    
    private func setUpMap() {
        mapView.showsUserLocation = true
        mapView.setRegion(self.getRegion(listOfPubs: self.listOfPubHeaders), animated:true)
        mapView.delegate = self
    }
    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let pubAnnotation = annotation as? PubAnnotation {
            return createPubAnnotationView(annotation: pubAnnotation)
        } else {
            //for user's location this means the view used is the blue blob instead of a pin.
            return nil
        }
    }
   
    func createPubAnnotationView(annotation: PubAnnotation) -> MKAnnotationView {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pubAnnotationView")
        annotationView.canShowCallout = true
        let button = UIButton(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = button
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? PubAnnotation {
            self.pubHeaderSelected = annotation.pubHeader
            performSegue(withIdentifier: K.SegueId.showDetail, sender: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pubDetailViewController = segue.destination as? PubDetailTableViewController {
                pubDetailViewController.pubHeader = self.pubHeaderSelected
        }
    }
    
    private func getRegion(listOfPubs:ListOfPubs) -> MKCoordinateRegion {
        
        switch listOfPubs.pubHeaders.count {
            case 0:
                return MKCoordinateRegion()
            case 1:
                let span = MKCoordinateSpanMake(K.MapView.minSpan, K.MapView.minSpan)
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
    
    private func addPubstoMap() {
        for pubHeader in self.listOfPubHeaders.pubHeaders{
            self.addPubToMap(pubHeader: pubHeader)
        }
    }
    
    private func addPubToMap(pubHeader:PubHeader) {
        let annotation = PubAnnotation(pubHeader: pubHeader)
        mapView.addAnnotation(annotation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    class PubAnnotation:NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D
        var title: String? {return pubHeader.name }
        var subtitle: String? { return pubHeader.town }
        let pubHeader:PubHeader
        init(pubHeader:PubHeader) {
            self.coordinate = CLLocationCoordinate2D(latitude:pubHeader.location.lat, longitude:pubHeader.location.lng )
            self.pubHeader = pubHeader
        }
    }
}

extension PubCrawlMapViewController:PubCreatorDelegate {
    func getPubLocations() {
        for (ndx, pubHeader) in self.listOfPubHeaders.pubHeaders.enumerated() {
            if ndx <= K.MapView.maxPubsToFetch {
                PubCreator(withDelegate:self, forPubHeader: pubHeader).createPub()
            } else {
                if ndx == (K.MapView.maxPubsToFetch + 1) {
                    self.showErrorMessage(withMessage: "Only showing first \(K.MapView.maxPubsToFetch) pubs", withTitle:"Warning")
                }
            }
        }
    }
    
    func finishedCreating(newPub pub:Pub) {
        self.addPubToMap(pubHeader: pub.pubHeader)
        self.newListOfPubHeaders.append(pub.pubHeader)
        self.listOfPubHeaders = ListOfPubs(using:newListOfPubHeaders, existingList:self.listOfPubHeaders)
        
        if self.listOfPubHeaders.count == 1 || self.listOfPubHeaders.count == 10  {
            self.setUpMap()
        }
    }
}

