//
//  Shop+CoreDataProperties.swift
//  MadridShopping
//
//  Created by JJLZ on 5/15/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import Foundation
import CoreData


extension Shop {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Shop> {
        return NSFetchRequest<Shop>(entityName: "Shop")
    }

    @NSManaged public var address: String?
    @NSManaged public var descriptionEN: String?
    @NSManaged public var descriptionES: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var latitude: String?
    @NSManaged public var logitude: String?
    @NSManaged public var logoURL: String?
    @NSManaged public var name: String?

}
