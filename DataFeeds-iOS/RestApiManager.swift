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
    
    func getLatestData(_ onCompletion: @escaping (JSON) -> Void) {
        
        let key = UserDefaultsManager.sharedInstance.getAIOkey()
        
        let route = baseURL
        makeHTTPGetRequest(route, key: key, onCompletion: { json, err in
                onCompletion(json as JSON)
        })
    }
    
    func getHistoricalDataBasedOnLimit(_ feedkey: String, limit: String, onCompletion: @escaping (JSON) -> Void) {
        
        let key = UserDefaultsManager.sharedInstance.getAIOkey()
        
        let route = baseURLhistorical + feedkey + baseURLhistorical1 + limit
        makeHTTPGetRequest(route, key: key, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    func getHistoricalDataBasedOnStartTime(_ feedkey: String, starttime: String, onCompletion: @escaping (JSON) -> Void) {
        
        let key = UserDefaultsManager.sharedInstance.getAIOkey()
        
        let route = baseURLhistorical + feedkey + baseURLhistorical2 + starttime
        makeHTTPGetRequest(route, key: key, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    func makeHTTPGetRequest(_ path: String, key: String, onCompletion: @escaping ServiceResponse) {
        let request = NSMutableURLRequest(url: URL(string: path)!)
        request.addValue(key, forHTTPHeaderField: "X-AIO-Key")
        
        let session = URLSession.shared
    
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            guard error == nil else {
                onCompletion(JSON([]), error as NSError?)
                return
            }
            guard let data = data else {
                onCompletion(JSON([]), error as NSError?)
                return
            }
            
            let json = try! JSON(data: data)
            onCompletion(json, error as NSError?)
        })
        
        task.resume()
    }
}
