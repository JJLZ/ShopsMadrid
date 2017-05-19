//
//  DetailViewController.swift
//  MadridShopping
//
//  Created by JJLZ on 5/19/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    // MARK: IBOutlet's
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var ivShop: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnClose: UIButton!
    
    // MARK: Properties
    var shop:Shop? = nil
    
    // MARK: ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-- Show info --
        if let s = shop
        {
            lblName.text = s.name
            lblDescription.text = s.descriptionES
            lblAddress.text = "Dirección: " + s.address!
            ivShop.image = UIImage(data: s.imageData! as Data)
        }
        
        //-- Map Setup --//
        setShopLocation(shop: shop!)
        
        mapView.delegate = self
        if let pin = createMapPin(shop: shop!)
        {
            mapView.addAnnotation(pin)
        }
        //--
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: MapView Methods
    
    func createMapPin(shop: Shop) -> MapPin?
    {
        var pin: MapPin? = nil
        
        guard shop.latitude != nil, shop.logitude != nil else { return pin }
        
        let lat = shop.latitude!.trimmingCharacters(in: .whitespaces).toDouble()
        let lon = shop.logitude!.trimmingCharacters(in: .whitespaces).toDouble()
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        pin = MapPin(coordinate: coordinate, title: shop.name)
        
        return pin
    }
    
    func setShopLocation(shop: Shop)
    {
        guard shop.latitude != nil, shop.logitude != nil else { return }
        
        let latitude = shop.latitude!.trimmingCharacters(in: .whitespaces).toDouble()
        let longitude = shop.logitude!.trimmingCharacters(in: .whitespaces).toDouble()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = 200
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: IBActions
    
    @IBAction func closeDetailView(_ sender: Any) {
        
        self.dismiss(animated: true) {}
    }
}

extension DetailViewController: MKMapViewDelegate
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
                view.canShowCallout = false
            }
            
            view.pinTintColor = UIColor.blue
            
            return view
        }
        
        return nil
    }
}





























