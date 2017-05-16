//
//  AppDelegate.swift
//  MadridShopping
//
//  Created by JJLZ on 5/12/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // get the complete path for the sqlite file
//        CoreDataStack.sharedInstance.applicationDocumentsDirectory()
        
        //--newcode now --//
        // Clear data
//        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
//        let processing = JSONProcessing(url: getLocalJSONPath(), context: context)
//        processing.clearData(context: context)
        
        return true
    }
    
    //--newcode now --//
    func getLocalJSONPath() -> URL
    {
        var url = Downloader.applicationDocumentsDirectory()
        url.appendPathComponent(Global.Constant.jsonLocalName)
        
        return url
    }
    
    func applicationWillTerminate(_ application: UIApplication)
    {
        CoreDataStack.sharedInstance.saveContext()
    }
}































