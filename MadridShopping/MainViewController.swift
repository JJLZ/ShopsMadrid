//
//  ViewController.swift
//  MadridShopping
//
//  Created by JJLZ on 5/12/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import UIKit

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
}

class MainViewController: UIViewController {
    
    // MARK: Outlet's
    @IBOutlet weak var vIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnTryAgain: UIButton!
    @IBOutlet weak var btnShowShops: UIButton!

    // MARK: View Controller Life cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Initial state
        setStateControls(state: .Downloading)
        
        // Download JSON file
        downloadQueue.addOperation(DownloadJSON(mainVC: self))
        
        // load json to sqlite storage using CoreData
        // load data from sqlite storage using CoreData
        // update UI
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Methods

    @IBAction func tryLoadDataAgain(_ sender: Any) {
        
        viewDidLoad()
    }
    
    //--newcode now --//
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
        case .NoInternet:
            vIndicator.stopAnimating()
            btnTryAgain.isHidden = false
            btnShowShops.isHidden = true
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
    
    // MARK: Navigation
    
    //--newcode now --//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
//    {
//        super.prepare(for: segue, sender: sender)
//        
//        if segue.identifier == "showShopsVC"
//        {
//            let nav = segue.destination as! UINavigationController
//            let shopsVC = nav.viewControllers.first as! ShopsViewController
//        }
//    }
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
                            downloadQueue.addOperation(LoadData(mainVC:self.mainVC))
                            
                            //--newcode now --//
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
                    
                    //--newcode now --//
                    self.mainVC.setStateControls(state: .NoInternet)
                }
            }
        }
        else    // continue con second operation
        {
            DispatchQueue.main.async {
                downloadQueue.addOperation(LoadData(mainVC:self.mainVC))
                
                //--newcode now --//
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

class LoadData: Operation
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
        let processing = JSONProcessing(url: getLocalJSONPath(), context: self.context)
        
        processing.getDataWith { (result) in
            
            switch result
            {
            case .Success(let data):
                
                processing.saveInCoreDataWith(array: data)
                
                //--newcode show --
                self.mainVC.performSegue(withIdentifier: "showShopsVC", sender: nil)
                //--
                
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





























