//
//  RestApiManager.swift
//  DataFeeds
//
//  Code for how to parse JSON from a REST API is based on the following article:
//  https://devdactic.com/parse-json-with-swift/
//
//  Created by Paula Petcu on 9/3/16.
//  Copyright © 2016 monohelixlabs. All rights reserved.
//

import Foundation

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    
    let baseURL = "https://io.adafruit.com/api/v1/feeds"
    
    let baseURLhistorical = "https://io.adafruit.com/api/v1/feeds/"
    let baseURLhistorical1 = "/data?limit="
    let baseURLhistorical2 = "/data?start_time="
    
    func getLatestData(onCompletion: (JSON) -> Void) {
        
        let key = UserDefaultsManager.sharedInstance.getAIOkey()
        
        let route = baseURL
        makeHTTPGetRequest(route, key: key, onCompletion: { json, err in
                onCompletion(json as JSON)
        })
    }
    
    func getHistoricalDataBasedOnLimit(feedkey: String, limit: String, onCompletion: (JSON) -> Void) {
        
        let key = UserDefaultsManager.sharedInstance.getAIOkey()
        
        let route = baseURLhistorical + feedkey + baseURLhistorical1 + limit
        makeHTTPGetRequest(route, key: key, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    func getHistoricalDataBasedOnStartTime(feedkey: String, starttime: String, onCompletion: (JSON) -> Void) {
        
        let key = UserDefaultsManager.sharedInstance.getAIOkey()
        
        let route = baseURLhistorical + feedkey + baseURLhistorical2 + starttime
        makeHTTPGetRequest(route, key: key, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    func makeHTTPGetRequest(path: String, key: String, onCompletion: ServiceResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        request.addValue(key, forHTTPHeaderField: "X-AIO-Key")
        
        let session = NSURLSession.sharedSession()
    
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if data != nil {
                let json:JSON = JSON(data: data!)
                onCompletion(json, error)
            }
            else {
                onCompletion(JSON([]), error)
            }
            })
        task.resume()
    }
}
