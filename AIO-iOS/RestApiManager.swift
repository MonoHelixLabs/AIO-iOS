//
//  RestApiManager.swift
//  MyFridge
//
//  Created by Paula Petcu on 9/3/16.
//  Copyright © 2016 monohelix. All rights reserved.
//

import Foundation

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    
    // TO-DO: store the key on phone, ask the user to enter the key first time the app is used, and create a view where this key can be changed, also display a message on main view that if no feeds are available, then check the key first
    
    let baseURL = "https://io.adafruit.com/api/feeds?x-aio-key="
    
    func getLatestData(onCompletion: (JSON) -> Void) {
        let prefs = NSUserDefaults.standardUserDefaults()
        var key = prefs.stringForKey("aiokey")
        if (key == nil) { key = "" }
        
        let route = baseURL + key!
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