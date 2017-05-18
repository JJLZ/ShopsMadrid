//
//  ShopsViewController.swift
//  MadridShopping
//
//  Created by JJLZ on 5/15/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class ShopsViewController: UIViewController, UITableViewDataSource {
    
    // MARK: IBOutlet's
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Properties
    private let cellID = "cellShop"
    let context = CoreDataStack.sharedInstance.persistentContainer.viewContext

    let regionRadius: CLLocationDistance = 1000
    var mapPins: [MapPin] = [MapPin]()
    
    lazy var frc: NSFetchedResultsController<Shop> = {
        let req: NSFetchRequest<Shop> = Shop.fetchRequest()
        req.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key:"name", ascending:true)
        req.sortDescriptors = [sortDescriptor]
        let afrc = NSFetchedResultsController(
            fetchRequest:req,
            managedObjectContext:self.context,
            sectionNameKeyPath:nil, cacheName:nil)
        do {
            try afrc.performFetch()
        } catch {
            fatalError("Aborting with unresolved error")
        }
        return afrc
    }()
    
    // MARK: ViewController Life Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //-- Map View Setup --
        mapView.delegate = self
        
        // set initial location in Madrid
        let initialLocation = CLLocation(latitude: 40.4165000, longitude: -3.7025600)
        centerMapOnLocation(initialLocation)

        // Show shops in the map view
        self.mapPins = createMapPins(frc: self.frc)
        mapView.addAnnotations(mapPins)
        //--
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return self.frc.sections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let sectionInfo = self.frc.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath) as! ShopTableViewCell
        
        let shop: Shop = self.frc.object(at: indexPath)
        cell.lblName.text = shop.name
        cell.ivImage.image = UIImage(data: shop.logoData! as Data)
        
        return cell
    }
    // MARK: MapKit
    
    func centerMapOnLocation(_ location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}




























