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
        // Is json file in local?
        if !isJSONInLocal() // json is not in local
        {
            // Download json
            // Check
            if isInternetAvailable() // Internet connection available
            {
                if let url = URL(string: Global.AppURL.jsonRemoteURL)
                {
                    // url for local json file
                    var jsonFileUrl = Downloader.applicationDocumentsDirectory()
                    jsonFileUrl.appendPathComponent(Global.Constant.jsonLocalName)
                 
                    // Download json to local
                    Downloader.load(url: url, to: jsonFileUrl, completion: {
                        
                        // update flag
                        let defaults = UserDefaults.standard
                        defaults.set(true, forKey: Global.UserDefaults.jsonDownloaded)
                        defaults.synchronize()
                    })
                }
            }
            else    // No Internet connection > show alert to the user
            {
                let alertController = UIAlertController(title          : "Internet not available",
                                                        message        : "Connection required to download shops info, please connect.",
                                                        preferredStyle : .alert)
                
                let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
                    
                    fatalError(Global.ErrorMessage.errorLoadingJSONFile)
                })
                
                alertController.addAction(actionCancel)
                
                DispatchQueue.main.async {
                    
                    self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        // load json to sqlite storage using CoreData
        // load data from sqlite storage using CoreData
        // update UI
        
        return true
    }
    
    func isJSONInLocal() -> Bool
    {
        let defaults = UserDefaults.standard
        
        return defaults.bool(forKey: Global.UserDefaults.jsonDownloaded)
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MadridShopping")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

