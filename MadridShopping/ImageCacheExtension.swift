//
//  ImageCacheExtension.swift
//  MadridShopping
//
//  Created by JJLZ on 5/12/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView
{
    func loadImageUsingCacheWithURLString(_ URLString: String, placeHolder: UIImage?)
    {
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: NSString(string: URLString))
        {
            self.image = cachedImage
            
            return
        }
        
        if let url = URL(string: URLString)
        {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in

                if error != nil
                {
                    print("Error Loading Images From URL: \(String(describing: error?.localizedDescription))")
                    
                    DispatchQueue.main.async
                    {
                        self.image = placeHolder
                    }
                    
                    return
                }
                
                DispatchQueue.main.async
                {
                    if let data = data
                    {
                        if let downloadedImage = UIImage(data: data)
                        {
                            imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
                            self.image = downloadedImage
                            
                            //--newcode now --
                            print("image downloaded with url" + URLString)
                            //--
                        }
                    }
                }
            }).resume()
        }
    }
}
