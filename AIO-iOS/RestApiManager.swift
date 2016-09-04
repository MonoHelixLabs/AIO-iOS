//
//  RestApiManager.swift
//  AIO-iOS
//
//  Code for how to parse JSON from a REST API is based on the following article:
//  https://devdactic.com/parse-json-with-swift/
//
//  Created by Paula Petcu on 9/3/16.
//  Copyright © 2016 monohelix. All rights reserved.
//

import Foundation

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    
    let baseURL = "https://io.adafruit.com/api/feeds?x-aio-key="
    
    func getLatestData(onCompletion: (JSON) -> Void) {
        
        let key = UserDefaultsManager.sharedInstance.getAIOkey()
        
        let route = baseURL + key
        makeHTTPGetRequest(route, onCompletion: { json, err in
                onCompletion(json as JSON)
        })
    }
    
    func makeHTTPGetRequest(path: String, onCompletion: ServiceResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let json:JSON = JSON(data: data!)
            onCompletion(json, error)
        })
        task.resume()
    }
}