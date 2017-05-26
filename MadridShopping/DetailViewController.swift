//
//  DetailViewController.swift
//  MadridShopping
//
//  Created by JJLZ on 5/19/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    // MARK: IBOutlet's
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var ivShop: UIImageView!
    @IBOutlet weak var mapView: UIImageView!
    @IBOutlet weak var btnClose: UIButton!
    
    // MARK: Properties
    var shop:Shop? = nil
    
    // MARK: ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showShopInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: Methods
    
    func showShopInfo()
    {
        let strLanguajeCode = Locale.current.languageCode
        
        if let s = shop
        {
            lblName.text = s.name
            ivShop.image = UIImage(data: s.imageData! as Data)
            mapView.image = UIImage(data: s.mapData! as Data)
            
            if strLanguajeCode == "es"
            {
                lblDescription.text = s.descriptionES
                btnClose.setTitle("Cerrar",for: .normal)
                lblAddress.text = "Dirección: " + s.address!
            }
            else
            {
                lblDescription.text = s.descriptionEN
                btnClose.setTitle("Close",for: .normal)
                lblAddress.text = "Address: " + s.address!
            }
        }
    }
    
    // MARK: IBActions
    
    @IBAction func closeDetailView(_ sender: Any) {
        
        self.dismiss(animated: true) {}
    }
}



























