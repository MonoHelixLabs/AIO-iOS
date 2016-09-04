//
//  UserDefaultsManager.swift
//  AIO-iOS
//
//  Created by Paula Petcu on 9/4/16.
//  Copyright © 2016 monohelix. All rights reserved.
//

import Foundation

class UserDefaultsManager: NSObject {
    
    static let sharedInstance = UserDefaultsManager()
    
    let aiokeyString = "aiokey"
    let aiokeyNotFound = ""
    
    func getAIOkey() -> String {
 
        let prefs = NSUserDefaults.standardUserDefaults()
        var key = prefs.stringForKey(aiokeyString)
        if (key == nil) { key = aiokeyNotFound }
        return key!
    }
    
    func setAIOkey(aiokey: String) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(aiokey, forKey: aiokeyString)
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    
}