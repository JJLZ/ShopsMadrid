/**
 *   Downloader
 */

import Foundation

class Downloader {
    
    class func applicationDocumentsDirectory() -> URL {
        
        let pathDocumentDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return pathDocumentDirectory
    }
    
    class func load(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            
            if let tempLocalUrl = tempLocalUrl, error == nil {
                
                // Success
//                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
//                    print("Downloader load Success: \(statusCode)")
//                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                    completion()
                } catch (let writeError) {
                    print("Error writing file \(localUrl) : \(writeError)")
                }
                
            } else {
                print("Failure: %@", error?.localizedDescription ?? "error desconocido");
                fatalError("Error while loading file")
            }
        }
        task.resume()
    }
}






























