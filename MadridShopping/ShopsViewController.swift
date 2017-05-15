//
//  ShopsViewController.swift
//  MadridShopping
//
//  Created by JJLZ on 5/15/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import UIKit
import CoreData

class ShopsViewController: UIViewController, UITableViewDataSource {
    
    // MARK: IBOutlet's
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    private let cellID = "cellShop"
    let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
    
    lazy var frc: NSFetchedResultsController<Shop> = {
        let req: NSFetchRequest<Shop> = Shop.fetchRequest()
        req.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key:"name", ascending:true)
        req.sortDescriptors = [sortDescriptor]
        let afrc = NSFetchedResultsController(
            fetchRequest:req,
            managedObjectContext:self.context,
            sectionNameKeyPath:nil, cacheName:nil)
        afrc.delegate = self
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
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath)
        
        let shop: Shop = self.frc.object(at: indexPath)
        cell.textLabel?.text = shop.name

        return cell
    }
}

extension ShopsViewController: NSFetchedResultsControllerDelegate
{
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        switch type
        {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
            
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.beginUpdates()
    }
}






























