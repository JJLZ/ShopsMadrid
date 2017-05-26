//
//  ImageCache.swift
//  MadridShopping
//
//  Created by JJLZ on 5/12/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import UIKit

class ImageCache: NSObject
{
    let cache = NSCache<NSString, UIImage>()
    
    static let sharedInstance: ImageCache = { ImageCache()} ()
    
    func imageFromCacheWithURLString(_ URLString: String, defaultImageName: String = "shop" ) -> UIImage
    {
        var image: UIImage? = nil
        
        if let cachedImage = cache.object(forKey: NSString(string: URLString))
        {
            image = cachedImage
            return image!
        }
        else
        {
            return UIImage(named: defaultImageName)!
        }
    }
    
    func cacheImageWithURLString(_ URLString: String, group: DispatchGroup)
    {
        group.enter()
        
        if let url = URL(string: URLString)
        {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in

                if error != nil
                {
                    print("Error Loading Images From URL: " + (error?.localizedDescription)!)
                    group.leave()
                    
                    return
                }
                
                if let data = data
                {
                    if let downloadedImage = UIImage(data: data)
                    {
                        self.cache.setObject(downloadedImage, forKey: NSString(string: URLString))
                        group.leave()
                    }
                    else
                    {
                        group.leave()
                        return
                    }
                }
                else
                {
                    group.leave()
                    return
                }

            }).resume()
        }
        else {
            group.leave()
            return
        }
    }
    
    public func getShopMapURL(latitude: String, longitude: String) -> String
    {
        let strCoordinates = String(latitude + "," + longitude)!
        
        return "http://maps.googleapis.com/maps/api/staticmap?center=" + strCoordinates + "&zoom=17&size=320x220&scale=2&markers=%7Ccolor:0x9C7B14%7C" + strCoordinates
    }

}






























