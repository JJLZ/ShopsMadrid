//
//  MapPin.swift
//  MadridShopping
//
//  Created by JJLZ on 5/17/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapPin: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?)
    {
        self.coordinate = coordinate
        self.title = title
    }
}

func createMapPins(frc: NSFetchedResultsController<Shop>) -> [MapPin]
{
    var pins = [MapPin]()
    
    for shop in frc.fetchedObjects! {
        
        guard shop.latitude != nil, shop.logitude != nil else { continue }
        
        // Get coordinate
        let lat = shop.latitude!.trimmingCharacters(in: .whitespaces).toDouble()
        let lon = shop.logitude!.trimmingCharacters(in: .whitespaces).toDouble()
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        let pin = MapPin(coordinate: coordinate, title: shop.name)
//        let pin = MapPin(coordinate: CLLocationCoordinate2D(latitude: 40.4165000, longitude: -3.7025600), title: "test")
        
        pins.append(pin)
    }
    
    return pins
}

extension ShopsViewController: MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if let annotation = annotation as? MapPin
        {
            let identifier = "mapPin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            {
                dequeuedView.annotation = annotation
                view = dequeuedView
            }
            else
            {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            
            view.pinTintColor = UIColor.red
            
            return view
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        //        let location = view.annotation as! Artwork
        //        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        //        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}

extension String
{
    func toDouble() -> Double
    {
        if let unwrappedNum = Double(self)
        {
            return unwrappedNum
        }
        else
        {
            print("Error converting \"" + self + "\" to Double")
            return 0.0
        }
    }
}
































