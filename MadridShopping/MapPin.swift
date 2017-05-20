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
    var indexPath: IndexPath
    
    init(coordinate: CLLocationCoordinate2D, title: String?, indexPath: IndexPath)
    {
        self.coordinate = coordinate
        self.title = title
        self.indexPath = indexPath
    }
}

func createMapPins(frc: NSFetchedResultsController<Shop>) -> [MapPin]
{
    var pins = [MapPin]()
    let total = frc.fetchedObjects?.count
    
    for index in 0..<total!
    {
        let indexPath = IndexPath(row: index, section: 0)
        
        let shop: Shop = frc.object(at: indexPath)
        
        guard shop.latitude != nil, shop.logitude != nil else { continue }
        
        let lat = shop.latitude!.trimmingCharacters(in: .whitespaces).toDouble()
        let lon = shop.logitude!.trimmingCharacters(in: .whitespaces).toDouble()
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        let pin = MapPin(coordinate: coordinate, title: shop.name, indexPath: indexPath)
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
            
            //-- Imagen para el Callout --
            let shop: Shop = self.frc.object(at: annotation.indexPath)
            let ivLogo = UIImageView(image: UIImage(data: shop.logoData! as Data))
            view.detailCalloutAccessoryView = ivLogo
            //--
            
            view.pinTintColor = UIColor.red
            
            return view
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        let shop = view.annotation as! MapPin
        self.selectedShop = frc.object(at: shop.indexPath)
        performSegue(withIdentifier: "showDetail", sender: self)
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
































