//
//  JSONProcessing.swift
//  MadridShopping
//
//  Created by JJLZ on 5/12/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// Here we create an enum with associated values and constrained to a generic type
enum Result<T> {
    case Success(T)
    case Error(String)
}

class JSONProcessing: NSObject
{
    var localURL: URL
    let context: NSManagedObjectContext
    
    init(url: URL, context: NSManagedObjectContext)
    {
        self.localURL = url
        self.context = context
    }
    
    func getDataWith(completion: @escaping (Result<[[String: AnyObject]]>) -> Void)
    {
        URLSession.shared.dataTask(with: self.localURL) { (data, response, error) in
            
            guard error == nil else { return completion(.Error(error!.localizedDescription)) }
            guard let data = data else { return completion(.Error(error?.localizedDescription ?? "There are no new Items to show"))
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                    guard let itemsJsonArray = json["result"] as? [[String: AnyObject]] else {
                        return completion(.Error(error?.localizedDescription ?? "There are no new Items to show"))
                    }
                    DispatchQueue.main.async {
                        completion(.Success(itemsJsonArray))
                    }
                }
            } catch let error {
                return completion(.Error(error.localizedDescription))
            }
            }.resume()
    }
    
    // MARK: Core Data
    
    private func createShopEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject?
    {
        if let shopEntity = NSEntityDescription.insertNewObject(forEntityName: "Shop", into: self.context) as? Shop
        {
            shopEntity.logitude = dictionary["gps_lat"] as? String
            shopEntity.latitude = dictionary["gps_lon"] as? String
            shopEntity.name = dictionary["name"] as? String
            shopEntity.logoURL = dictionary["logo_img"] as? String
            shopEntity.imageURL = dictionary["img"] as? String
            shopEntity.descriptionES = dictionary["description_es"] as? String
            shopEntity.descriptionEN = dictionary["description_en"] as? String
            shopEntity.address = dictionary["address"] as? String
            
            return shopEntity
        }
        
        return nil
    }
    
    func saveInCoreDataWith(array: [[String: AnyObject]])
    {
        _ = array.map{self.createShopEntityFrom(dictionary: $0)}
        do
        {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        }
        catch let error
        {
            print(error)
        }
    }
    
    func clearData(context: NSManagedObjectContext)
    {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shop")
            
            do
            {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                CoreDataStack.sharedInstance.saveContext()
            }
            catch let error
            {
                print("Error Deleting: \(error)")
            }
        }
    }
}
































