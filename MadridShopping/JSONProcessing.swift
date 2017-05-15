/**
 *   JSONProcessing.swift
 */

import Foundation
import UIKit

// MARK: Aliases

typealias JSONObject        = AnyObject
typealias JSONDictionary    = [String : JSONObject]
typealias JSONArray         = [JSONDictionary]

// MARK: - Loading

func loadJsonFileFrom(localUrl: URL) throws -> JSONArray {
    
    if let data = try? Data(contentsOf: localUrl),
        let maybeArray: Any = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) {
        
        if let array = (maybeArray as? NSArray) as Array? { // Es un array de diccionarios
            
            return (array as? JSONArray)!
            
        } else if let dic = (maybeArray as? NSDictionary) as Dictionary? { // Es un diccionario
            
            // metemos el diccionario dentro de un array antes de regresarlo
            let array: [JSONDictionary] = [dic as! JSONDictionary]
            
            return array
        } else {    // formato de json incorrecto
            
            throw Global.Errors.wrongJSONFormat
        }
        
    } else {    // formato de json incorrecto
        throw Global.Errors.wrongJSONFormat
    }
}

// MARK: Decoding

//func decode(book json: JSONDictionary) throws -> Book {
//    
//    guard let pdfUrlString = json["pdf_url"] as? String, let pdfUrl = URL(string: pdfUrlString) else {
//        
//        throw HackerBooksErrors.wrongURLFormatForJSONResource
//    }
//    
//    guard let imageUrlString = json["image_url"] as? String, let imageUrl = URL(string: imageUrlString) else {
//        
//        throw HackerBooksErrors.wrongURLFormatForJSONResource
//    }
//    
//    //-- Extraer autores --
//    let authors: [String]
//    if let authorsString = json["authors"] {
//        
//        authors = createAuthorsArrayFrom(authors: authorsString as! String)
//    } else {
//        
//        throw HackerBooksErrors.wrongURLFormatForJSONResource
//    }
//    //--
//    
//    //-- Extraer tags --
//    let tags: [Tag]
//    if let stringTags = json["tags"] {
//        
//        tags = createTagArrayFrom(tagString: stringTags as! String)
//    } else {
//        
//        throw HackerBooksErrors.wrongURLFormatForJSONResource
//    }
//    //--
//    
//    let title = json["title"] as! String
//    
//    // Creamos el book
//    return Book(title: title, authors: authors, tags: tags, imageUrl: imageUrl, pdfUrl: pdfUrl)
//}
//
//func createAuthorsArrayFrom(authors: String) -> [String] {
//    
//    let firstArray = authors.components(separatedBy: ",")
//    var finalArray: [String] = []
//    
//    // Eliminar espacios en blanco a los extremos de cada author
//    for author in firstArray {
//        finalArray.append(author.trimmingCharacters(in: .whitespaces))
//    }
//    
//    return finalArray
//}
//
//func createTagArrayFrom(tagString: String) -> [Tag] {
//    
//    let firstArray = tagString.components(separatedBy: ",")
//    var tagArray: [Tag] = []
//    
//    for tag in firstArray {
//        
//        // Eliminar espacios en blanco y crear Tag elements
//        tagArray.append(Tag(name: tag.trimmingCharacters(in: .whitespaces)))
//    }
//    
//    return tagArray
//}






























