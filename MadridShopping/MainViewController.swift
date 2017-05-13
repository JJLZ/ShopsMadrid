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

class MainViewController: UIViewController {
    
    // MARK: Outlet's
    @IBOutlet weak var vIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnTryAgain: UIButton!
    @IBOutlet weak var btnShowShops: UIButton!

    // MARK: View Controller Life cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Initial setup
        btnTryAgain.isHidden = true
        btnShowShops.isHidden = true
        
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
            self.mainVC.vIndicator.startAnimating()
            
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
                            self.mainVC.vIndicator.stopAnimating()
                            downloadQueue.addOperation(LoadData())
                            //--newcode now --//
                            self.mainVC.btnTryAgain.isHidden = true
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
                    self.mainVC.vIndicator.stopAnimating()
                    self.mainVC.btnTryAgain.isHidden = false
                    self.mainVC.present(alertController, animated: true, completion: {})
                }
            }
        }
        else
        {
            DispatchQueue.main.async {
                self.mainVC.vIndicator.stopAnimating()
                downloadQueue.addOperation(LoadData())
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
    override func main() {
        print("Es hora de la segunda operación")
    }
}





























