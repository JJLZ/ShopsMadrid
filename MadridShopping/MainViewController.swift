//
//  ViewController.swift
//  MadridShopping
//
//  Created by JJLZ on 5/12/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import UIKit
import CoreData

// MARK: Properties
var downloadQueue: OperationQueue = {
    var queue = OperationQueue()
    queue.name = "Download queue"
    queue.maxConcurrentOperationCount = 1
    return queue
}()

enum MainVCState {
    case Downloading
    case Ready
    case NoInternet
    case Error
}

class MainViewController: UIViewController {
    
    // MARK: Outlet's
    @IBOutlet weak var vIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnTryAgain: UIButton!
    @IBOutlet weak var btnShowShops: UIButton!
    @IBOutlet weak var lblState: UILabel!
    
    // MARK: Properties
    let context = CoreDataStack.sharedInstance.persistentContainer.viewContext

    // MARK: View Controller Life cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
     
        initialSetup()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: Methods

    @IBAction func tryLoadDataAgain(_ sender: Any) {

        initialSetup()
    }
    
    func initialSetup()
    {
        // Check if I already have all data downloaded
        let defaults = UserDefaults.standard
        let blnDataReady: Bool = defaults.bool(forKey: Global.UserDefaults.allDataLoaded)
        
        if blnDataReady
        {
            // Initial state
            setStateControls(state: .Ready)
        }
        else
        {
            // Initial state
            setStateControls(state: .Downloading)
            
            // Download JSON file
            downloadQueue.addOperation(DownloadJSON(mainVC: self))
        }
    }
    
    func updateStateLabelWithMesssage(_ message: String = "")
    {
        lblState.text = message
    }

    func setStateControls(state: MainVCState)
    {
        switch state
        {
        case .Downloading:
            vIndicator.startAnimating()
            btnTryAgain.isHidden = true
            btnShowShops.isHidden = true
        case .Ready:
            vIndicator.stopAnimating()
            btnTryAgain.isHidden = true
            btnShowShops.isHidden = false
            updateStateLabelWithMesssage("Ready to use!")
        case .NoInternet:
            vIndicator.stopAnimating()
            btnTryAgain.isHidden = false
            btnShowShops.isHidden = true
            updateStateLabelWithMesssage("Internet not detected!")
        case .Error:
            vIndicator.stopAnimating()
            btnTryAgain.isHidden = false
            btnShowShops.isHidden = false
            updateStateLabelWithMesssage("Error try again!")
        }
    }
    
    func showAlertWith(title: String, message: String, style: UIAlertControllerStyle = .alert)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        let action = UIAlertAction(title: title, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
    }
        
    // MARK: Actions
    @IBAction func showShops(_ sender: Any)
    {
        performSegue(withIdentifier: "showShopsVC", sender: nil)
    }
}

// Operation is an abstract class, designed for subclassing. Each subclass represents a specific task.
class DownloadJSON: Operation
{
    // MARK: Properties
    var mainVC: MainViewController
    
    // MARK: Init
    init(mainVC: MainViewController)
    {
        self.mainVC = mainVC
    }

    // main is the method you override in Operation subclasses to actually perform work
    override func main()
    {
        // Is json file in local?
        if !isJSONInLocal() // json is not in local
        {
            DispatchQueue.main.async {
                self.mainVC.updateStateLabelWithMesssage("Downloading JSON")
            }
            
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
                        
                        // Begins next Operation
                        DispatchQueue.main.async {
                            
                            downloadQueue.addOperation(DecodeJSON(mainVC:self.mainVC))
                            self.mainVC.setStateControls(state: .Downloading)
                        }
                    })
                }
            }
            else    // No Internet connection > show alert to the user
            {
                let alertController = UIAlertController(title          : "Internet not available",
                                                        message        : "Connection required to download shops info, please connect.",
                                                        preferredStyle : .alert)
                
                let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
                    
                })
                
                alertController.addAction(actionCancel)
                
                DispatchQueue.main.async {
                    self.mainVC.present(alertController, animated: true, completion: {})
                    self.mainVC.setStateControls(state: .NoInternet)
                }
            }
        }
        else    // continue con second operation
        {
            DispatchQueue.main.async {
                
                downloadQueue.addOperation(DecodeJSON(mainVC:self.mainVC))
                self.mainVC.setStateControls(state: .Downloading)
            }
        }
    }
    
    // MARK: Methods
    
    func isJSONInLocal() -> Bool
    {
        let defaults = UserDefaults.standard
        
        return defaults.bool(forKey: Global.UserDefaults.jsonDownloaded)
    }
}

class DecodeJSON: Operation
{
    // MARK: Properties
    var mainVC: MainViewController
    let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
    
    // MARK: Init
    init(mainVC: MainViewController)
    {
        self.mainVC = mainVC
    }
    
    override func main()
    {
        DispatchQueue.main.async {
            self.mainVC.updateStateLabelWithMesssage("Decoding JSON")
        }
        
        let processing = JSONProcessing(url: getLocalJSONPath(), context: self.context)
        
        processing.getDataWith { (result) in
            
            switch result
            {
            case .Success(let data):
                
                processing.saveInCoreDataWith(array: data, completionHandler: {_ in 
                
                    // Continue with cache of images
                    self.mainVC.setStateControls(state: .Downloading)
                    downloadQueue.addOperation(CacheImages(mainVC: self.mainVC))
                })
                
            case .Error(let message):   
                
                DispatchQueue.main.async {
                    self.mainVC.showAlertWith(title: "Error", message: message)
                }
            }
        }
    }
    
    func getLocalJSONPath() -> URL
    {
        var url = Downloader.applicationDocumentsDirectory()
        url.appendPathComponent(Global.Constant.jsonLocalName)

        return url
    }
}

class CacheImages: Operation
{
    // MARK: Properties
    var mainVC: MainViewController
    var context: NSManagedObjectContext
    
    // MARK: Init
    init(mainVC: MainViewController)
    {
        self.mainVC = mainVC
        self.context = mainVC.context
    }
    
    override func main()
    {
        DispatchQueue.main.async {
            self.mainVC.updateStateLabelWithMesssage("Downloading images")
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        let entityDesc = NSEntityDescription.entity(forEntityName: "Shop", in: context)
        request.entity = entityDesc
        do
        {
            let results = try context.fetch(request)
            
            let imageCache:ImageCache = ImageCache.sharedInstance
            let group = DispatchGroup()
            
            for item in results {
                
                let shop = item as! Shop
                let imageURL: String = shop.imageURL!
                let logoURL: String = shop.logoURL!
                
                imageCache.cacheImageWithURLString(imageURL, group: group)
                imageCache.cacheImageWithURLString(logoURL, group: group)
            }
                        
            group.notify(queue: DispatchQueue.main, execute: {
                
                downloadQueue.addOperation(SavingImages(mainVC: self.mainVC))
            })
        }
        catch
        {
            DispatchQueue.main.async {
                self.mainVC.showAlertWith(title: "Error", message: error.localizedDescription)
            }
        }
    }
}

class SavingImages: Operation
{
    // MARK: Properties
    var mainVC: MainViewController
    var context: NSManagedObjectContext
    
    // MARK: Init
    init(mainVC: MainViewController)
    {
        self.mainVC = mainVC
        self.context = mainVC.context
    }
    
    override func main()
    {
        DispatchQueue.main.async {
            self.mainVC.updateStateLabelWithMesssage("Saving images")
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        let entityDesc = NSEntityDescription.entity(forEntityName: "Shop", in: context)
        request.entity = entityDesc
        do
        {
            let results = try context.fetch(request)
            
            let imageCache:ImageCache = ImageCache.sharedInstance
            
            for item in results {
                
                let shop = item as! Shop
                let imageURL: String = shop.imageURL!
                let logoURL: String = shop.logoURL!
                
                let logo: UIImage = imageCache.imageFromCacheWithURLString(logoURL)
                let image: UIImage = imageCache.imageFromCacheWithURLString(imageURL)
                
                let logoData: Data = UIImageJPEGRepresentation(logo, 0.0)!
                let imageData: Data = UIImageJPEGRepresentation(image, 0.0)!
                
                shop.setValue(logoData, forKey: "logoData")
                shop.setValue(imageData, forKey: "imageData")
                
                do {
                    try context.save()
                } catch {
                    DispatchQueue.main.async {
                        self.mainVC.showAlertWith(title: "Error saving images", message: error.localizedDescription)
                        self.mainVC.setStateControls(state: .Error)
                        imageCache.cache.removeAllObjects()
                        return
                    }
                }
            }
            
            DispatchQueue.main.async {
                
                imageCache.cache.removeAllObjects()
                
                downloadQueue.addOperation(CacheMapImages(mainVC: self.mainVC))
            }
        }
        catch
        {
            DispatchQueue.main.async {
                let imageCache:ImageCache = ImageCache.sharedInstance
                imageCache.cache.removeAllObjects()
                
                self.mainVC.showAlertWith(title: "Error saving images", message: error.localizedDescription)
            }
        }
    }
}

class CacheMapImages: Operation
{
    // MARK: Properties
    var mainVC: MainViewController
    var context: NSManagedObjectContext
    
    // MARK: Init
    init(mainVC: MainViewController)
    {
        self.mainVC = mainVC
        self.context = mainVC.context
    }
    
    override func main()
    {
        DispatchQueue.main.async {
            self.mainVC.updateStateLabelWithMesssage("Downloading map images")
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        let entityDesc = NSEntityDescription.entity(forEntityName: "Shop", in: context)
        request.entity = entityDesc
        do
        {
            let results = try context.fetch(request)
            
            let imageCache:ImageCache = ImageCache.sharedInstance
            let group = DispatchGroup()
            
            for item in results {
                
                let shop = item as! Shop
                guard shop.latitude != nil, shop.logitude != nil else { continue }
                
                let mapURL = imageCache.getShopMapURL(latitude: shop.latitude!, longitude: shop.logitude!)
                imageCache.cacheImageWithURLString(mapURL, group: group)
            }
            
            group.notify(queue: DispatchQueue.main, execute: {
                
                downloadQueue.addOperation(SavingMapImages(mainVC: self.mainVC))
            })
        }
        catch
        {
            DispatchQueue.main.async {
                self.mainVC.showAlertWith(title: "Error Downloading map images", message: error.localizedDescription)
            }
        }
    }
}

class SavingMapImages: Operation
{
    // MARK: Properties
    var mainVC: MainViewController
    var context: NSManagedObjectContext
    
    // MARK: Init
    init(mainVC: MainViewController)
    {
        self.mainVC = mainVC
        self.context = mainVC.context
    }
        
    override func main()
    {
        DispatchQueue.main.async {
            self.mainVC.updateStateLabelWithMesssage("Saving map images")
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        let entityDesc = NSEntityDescription.entity(forEntityName: "Shop", in: context)
        request.entity = entityDesc
        do
        {
            let results = try context.fetch(request)
            
            let imageCache:ImageCache = ImageCache.sharedInstance
            
            for item in results {
                
                let shop = item as! Shop
                guard shop.latitude != nil, shop.logitude != nil else { continue }
                
                let mapURL =  imageCache.getShopMapURL(latitude: shop.latitude!, longitude: shop.logitude!)
                let mapImage: UIImage = imageCache.imageFromCacheWithURLString(mapURL, defaultImageName: "noMap")
                let imageData: Data = UIImageJPEGRepresentation(mapImage, 0.0)!
                
                shop.setValue(imageData, forKey: "mapData")
                
                do {
                    try context.save()
                } catch {
                    DispatchQueue.main.async {
                        self.mainVC.showAlertWith(title: "Error saving map images", message: error.localizedDescription)
                        self.mainVC.setStateControls(state: .Error)
                        imageCache.cache.removeAllObjects()
                        return
                    }
                }
            }
            
            DispatchQueue.main.async {
                
                imageCache.cache.removeAllObjects()
                
                // update flag
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: Global.UserDefaults.allDataLoaded)
                defaults.synchronize()
                
                self.mainVC.setStateControls(state: .Ready)
            }
        }
        catch
        {
            DispatchQueue.main.async {
                let imageCache:ImageCache = ImageCache.sharedInstance
                imageCache.cache.removeAllObjects()
                
                self.mainVC.showAlertWith(title: "Error saving map images", message: error.localizedDescription)
            }
        }
    }
}























