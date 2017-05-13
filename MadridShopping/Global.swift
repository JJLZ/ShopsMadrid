/**
 *   Global.swift
 *   http://stackoverflow.com/questions/26252233/global-constants-file-in-swift
 */

import Foundation
import UIKit

class Global
{
    struct Constant
    {
        static let jsonLocalName = "shops.json"
    }
    
    struct UserDefaults
    {
        static let jsonDownloaded = "jsonDocumentIsAlreadyDownloaded"
    }
    
    struct ErrorMessage
    {
        static let errorLoadingJSONFile = "Error while loading JSON file"
    }
    
    struct AppURL
    {
        static let jsonRemoteURL = "http://madrid-shops.com/json_new/getShops.php"
    }
}



























